// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';

class AddEditEquipmentScreen extends StatefulWidget {
  final String? equipmentId;
  final Map<String, dynamic>? initialData;

  const AddEditEquipmentScreen({super.key, this.equipmentId, this.initialData});

  @override
  State<AddEditEquipmentScreen> createState() => _AddEditEquipmentScreenState();
}

class _AddEditEquipmentScreenState extends State<AddEditEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _penaltyController = TextEditingController();
  XFile? _pickedImage;
  bool _pickingImage = false;

  bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _pickingImage = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (source == ImageSource.camera && !_isDesktop) {
        final status = await Permission.camera.request();
        if (!mounted) return;
        if (!status.isGranted) {
          messenger.showSnackBar(const SnackBar(content: Text('Camera permission denied')));
          return;
        }
      } else if (source == ImageSource.gallery && !_isDesktop) {
        final status = await Permission.photos.request();
        if (!mounted) return;
        if (!status.isGranted) {
          messenger.showSnackBar(const SnackBar(content: Text('Gallery permission denied')));
          return;
        }
      }
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: _isDesktop ? ImageSource.gallery : source,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (picked != null) setState(() => _pickedImage = picked);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _showImagePickerSheet() {
    if (_isDesktop) {
      _pickImage(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Select Image Source', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _penaltyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    if (data != null) {
      _nameController.text = (data['name'] ?? '').toString();
      _categoryController.text = (data['category'] ?? '').toString();
      _descriptionController.text = (data['description'] ?? '').toString();
      _quantityController.text = (data['quantity'] ?? '').toString();
      // penalty may not exist in Firestore schema; keep optional
      _penaltyController.text = (data['penalty'] ?? '').toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.equipmentId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Equipment" : "Add Equipment"),
        actions: [
          IconButton(
            onPressed: _saveEquipment,
            icon: const Icon(Icons.save),
            tooltip: 'Save',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Equipment Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Equipment Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter equipment name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: "Quantity Available",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _penaltyController,
                decoration: const InputDecoration(
                  labelText: "Penalty per Day (\$)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter penalty amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Equipment Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickingImage ? null : _showImagePickerSheet,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.withValues(alpha: 0.04),
                  ),
                  child: _pickingImage
                      ? const Center(child: CircularProgressIndicator())
                      : _pickedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: kIsWeb
                                  ? Image.network(_pickedImage!.path, fit: BoxFit.cover, width: double.infinity)
                                  : Image.file(File(_pickedImage!.path), fit: BoxFit.cover, width: double.infinity),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 48, color: Colors.blue.shade300),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isDesktop ? 'Tap to select image' : 'Tap to add image (Camera / Gallery)',
                                    style: TextStyle(color: Colors.blue.shade400),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
              if (_pickedImage != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _pickedImage = null),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Remove image', style: TextStyle(color: Colors.red)),
                  ),
                ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Builder(
                      builder: (builderContext) {
                        return Consumer<EquipmentProvider>(builder: (context, provider, _) {
                          return ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) return;
                                    try {
                                      if (isEdit) {
                                        await provider.updateEquipment(
                                          id: widget.equipmentId!,
                                          name: _nameController.text.trim(),
                                          category: _categoryController.text.trim(),
                                          quantity: int.parse(_quantityController.text.trim()),
                                          description: _descriptionController.text.trim(),
                                          penalty: double.tryParse(_penaltyController.text.trim()),
                                        );
                                      } else {
                                        await provider.addEquipment(
                                          name: _nameController.text.trim(),
                                          category: _categoryController.text.trim(),
                                          quantity: int.parse(_quantityController.text.trim()),
                                          description: _descriptionController.text.trim(),
                                          penalty: double.tryParse(_penaltyController.text.trim()),
                                        );
                                      }
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(isEdit ? 'Equipment updated' : 'Equipment added')),
                                      );
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red));
                                    }
                                  },
                            child: provider.isLoading ? const CircularProgressIndicator() : Text(isEdit ? 'Update Equipment' : 'Save Equipment'),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Called by the AppBar save icon — delegates to the provider just like
  /// the bottom Save button does, ensuring both paths actually persist data.
  Future<void> _saveEquipment() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<EquipmentProvider>();
    final isEdit = widget.equipmentId != null;
    try {
      if (isEdit) {
        await provider.updateEquipment(
          id: widget.equipmentId!,
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          quantity: int.parse(_quantityController.text.trim()),
          description: _descriptionController.text.trim(),
          penalty: double.tryParse(_penaltyController.text.trim()),
        );
      } else {
        await provider.addEquipment(
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          quantity: int.parse(_quantityController.text.trim()),
          description: _descriptionController.text.trim(),
          penalty: double.tryParse(_penaltyController.text.trim()),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Equipment updated successfully' : 'Equipment saved successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
      );
    }
  }
}