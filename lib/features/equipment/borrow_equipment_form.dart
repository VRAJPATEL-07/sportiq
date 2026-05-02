// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth_service_base.dart';
import '../../providers/borrowing_provider.dart';

class BorrowEquipmentForm extends StatefulWidget {
  final dynamic equipment; // Accept both Equipment and Map<String, dynamic>

  const BorrowEquipmentForm({super.key, required this.equipment});

  @override
  State<BorrowEquipmentForm> createState() => _BorrowEquipmentFormState();
}

class _BorrowEquipmentFormState extends State<BorrowEquipmentForm> {
  final _formKey = GlobalKey<FormState>();
  int _quantity = 1;
  DateTime? _borrowDate;
  DateTime? _returnDate;
  String? _purpose;
  String _borrowDuration = '1 Day';
  bool _agreeToTerms = false;

  // Helper methods to support both Map and Equipment types
  String _getEquipmentName() {
    final eq = widget.equipment;
    if (eq is Map) return eq['name']?.toString() ?? 'Unknown';
    return eq.name;
  }

  int _getEquipmentAvailable() {
    final eq = widget.equipment;
    if (eq is Map) {
      final q = (eq['quantity'] as int?) ?? 0;
      final a = eq['available'];
      if (a is int) return a;
      return q;
    }
    return eq.available;
  }

  IconData _getEquipmentIcon() {
    final eq = widget.equipment;
    if (eq is Map) return Icons.inventory_2; // Default icon for map
    return eq.icon;
  }

  @override
  void initState() {
    super.initState();
    _borrowDate = DateTime.now();
    _returnDate = DateTime.now().add(const Duration(days: 1));

    // Ensure the borrowing listener is active even if coming from QR scan
    // (the dashboard may not have been visited yet)
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      final auth = Provider.of<IAuthService>(context, listen: false);
      final userId = auth.current.userId;
      if (userId != null && userId.isNotEmpty) {
        Provider.of<BorrowingProvider>(context, listen: false)
            .initializeForUser(userId);
      }
    });
  }

  void _selectBorrowDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _borrowDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _borrowDate) {
      setState(() {
        _borrowDate = picked;
        _updateReturnDate();
      });
    }
  }

  void _selectReturnDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: _borrowDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _returnDate) {
      setState(() {
        _returnDate = picked;
        _updateDuration();
      });
    }
  }

  void _updateReturnDate() {
    if (_borrowDate != null) {
      switch (_borrowDuration) {
        case '1 Day':
          setState(() => _returnDate = _borrowDate!.add(const Duration(days: 1)));
          break;
        case '3 Days':
          setState(() => _returnDate = _borrowDate!.add(const Duration(days: 3)));
          break;
        case '1 Week':
          setState(() => _returnDate = _borrowDate!.add(const Duration(days: 7)));
          break;
        case '2 Weeks':
          setState(() => _returnDate = _borrowDate!.add(const Duration(days: 14)));
          break;
      }
    }
  }

  void _updateDuration() {
    if (_borrowDate != null && _returnDate != null) {
      final difference = _returnDate!.difference(_borrowDate!).inDays;
      if (difference == 1) {
        setState(() => _borrowDuration = '1 Day');
      } else if (difference == 3) {
        setState(() => _borrowDuration = '3 Days');
      } else if (difference == 7) {
        setState(() => _borrowDuration = '1 Week');
      } else if (difference == 14) {
        setState(() => _borrowDuration = '2 Weeks');
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Borrow Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfirmationRow('Equipment:', _getEquipmentName()),
              _buildConfirmationRow('Quantity:', '$_quantity'),
              _buildConfirmationRow('Borrow Date:', _formatDate(_borrowDate)),
              _buildConfirmationRow('Return Date:', _formatDate(_returnDate)),
              _buildConfirmationRow('Purpose:', _purpose ?? 'Not specified'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms & Conditions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Equipment must be returned in good condition\n• Late returns may incur penalties\n• You are responsible for any damage',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _borrowAndSave();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirm Borrow'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fill all fields and agree to terms'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _borrowAndSave() async {
    try {
      final auth = Provider.of<IAuthService>(context, listen: false);
      final borrowingProvider = Provider.of<BorrowingProvider>(context, listen: false);
      final equipmentId = widget.equipment['id']?.toString() ?? '';

      final userId = auth.current.userId;
      
      if (userId == null || userId.isEmpty || equipmentId.isEmpty) {
        throw Exception('Missing user ID or equipment ID');
      }

      // Ensure userName is always set
      final userName = (auth.current.displayName != null && auth.current.displayName!.trim().isNotEmpty)
          ? auth.current.displayName!.trim()
          : (auth.current.email != null && auth.current.email!.isNotEmpty 
              ? auth.current.email!.split('@').first.toUpperCase() 
              : 'User');
      
      // Get penalty from equipment data
      double? penalty;
      if (widget.equipment['penalty'] != null) {
        penalty = (widget.equipment['penalty'] as num).toDouble();
      }

      // Save borrowing record to Firestore
      await borrowingProvider.borrowEquipment(
        userId: userId,
        userName: userName,
        equipmentId: equipmentId,
        equipmentName: _getEquipmentName(),
        quantity: _quantity,
        borrowDate: _borrowDate ?? DateTime.now(),
        returnDate: _returnDate ?? DateTime.now().add(const Duration(days: 1)),
        purpose: _purpose ?? 'Not specified',
        penalty: penalty,
      );
      
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Borrow Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your equipment has been successfully borrowed!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Borrow Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Equipment: ${_getEquipmentName()}'),
                  const SizedBox(height: 4),
                  Text('Quantity: $_quantity'),
                  const SizedBox(height: 4),
                  Text('Return Date: ${_formatDate(_returnDate)}'),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Remember to return on time to avoid penalties',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Equipment borrowed successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not selected';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow Equipment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Equipment Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getEquipmentIcon(),
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getEquipmentName(),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Available: ${_getEquipmentAvailable()}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quantity Selection
                Text(
                  'Quantity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text(
                        '$_quantity',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _quantity < _getEquipmentAvailable()
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Borrow Duration
                Text(
                  'Borrow Duration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _borrowDuration,
                  items: ['1 Day', '3 Days', '1 Week', '2 Weeks']
                      .map((duration) => DropdownMenuItem(
                            value: duration,
                            child: Text(duration),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _borrowDuration = value;
                        _updateReturnDate();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Borrow Date',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectBorrowDate,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20),
                                  const SizedBox(width: 8),
                                  Text(_formatDate(_borrowDate)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Return Date',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectReturnDate,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 20),
                                  const SizedBox(width: 8),
                                  Text(_formatDate(_returnDate)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Purpose TextFormField
                Text(
                  'Purpose (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  onChanged: (value) => setState(() => _purpose = value),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter the purpose of borrowing...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),

                // Terms Agreement
                CheckboxListTile(
                  value: _agreeToTerms,
                  onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                  title: const Text('I agree to the terms and conditions'),
                  subtitle: const Text('Equipment must be returned in good condition'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Borrow'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
