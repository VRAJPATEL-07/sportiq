import 'package:flutter/material.dart';

class Equipment {
  final String id;
  final String name;
  final String description;
  final String category;
  final int quantity;
  final int available;
  final IconData icon;

  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.quantity,
    required this.available,
    required this.icon,
  });
}

class EquipmentList extends StatefulWidget {
  const EquipmentList({super.key});

  @override
  State<EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends State<EquipmentList> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isGridView = false;

  final List<Equipment> equipmentItems = [
    Equipment(
      id: '1',
      name: 'Football',
      description: 'Standard size football for matches and practice',
      category: 'Ball Sports',
      quantity: 10,
      available: 7,
      icon: Icons.sports_soccer,
    ),
    Equipment(
      id: '2',
      name: 'Cricket Bat',
      description: 'Wooden bat for cricket games and training',
      category: 'Bat Sports',
      quantity: 8,
      available: 4,
      icon: Icons.sports_cricket,
    ),
    Equipment(
      id: '3',
      name: 'Badminton Racket',
      description: 'Lightweight racket for badminton matches',
      category: 'Racket Sports',
      quantity: 15,
      available: 12,
      icon: Icons.sports_tennis,
    ),
    Equipment(
      id: '4',
      name: 'Basketball',
      description: 'Official size basketball for games',
      category: 'Ball Sports',
      quantity: 6,
      available: 3,
      icon: Icons.sports_basketball,
    ),
    Equipment(
      id: '5',
      name: 'Tennis Racket',
      description: 'Professional tennis racket for all levels',
      category: 'Racket Sports',
      quantity: 12,
      available: 8,
      icon: Icons.sports_tennis,
    ),
    Equipment(
      id: '6',
      name: 'Volleyball',
      description: 'Regulation volleyball for matches and practice',
      category: 'Ball Sports',
      quantity: 7,
      available: 5,
      icon: Icons.sports_volleyball,
    ),
    Equipment(
      id: '7',
      name: 'Table Tennis Paddle',
      description: 'High quality table tennis paddle',
      category: 'Racket Sports',
      quantity: 20,
      available: 18,
      icon: Icons.sports_tennis,
    ),
    Equipment(
      id: '8',
      name: 'Hockey Stick',
      description: 'Professional hockey stick for field hockey',
      category: 'Bat Sports',
      quantity: 10,
      available: 6,
      icon: Icons.sports_hockey,
    ),
  ];

  List<Equipment> get filteredItems {
    List<Equipment> items = equipmentItems;

    // Category filter
    if (_selectedCategory != 'All') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchController.text.isNotEmpty) {
      items = items.where((item) => item.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }

    return items;
  }

  Set<String> get categories {
    return {'All', ...equipmentItems.map((item) => item.category)};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEquipmentDetails(Equipment equipment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(equipment.category),
                        backgroundColor: Colors.blue.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
                Icon(
                  equipment.icon,
                  size: 48,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(equipment.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Quantity',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${equipment.quantity}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${equipment.available}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: equipment.available > 0 ? Colors.green : Colors.red,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: equipment.available > 0
                    ? () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/borrow_form', arguments: {'equipment': equipment});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening borrow form for ${equipment.name}'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(equipment.available > 0 ? 'Borrow This Item' : 'Not Available'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Equipment Catalog"),
        elevation: 0,
        actions: [
            IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/scan');
            },
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Equipment QR Code',
          ),
          IconButton(
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            icon: Icon(_isGridView ? Icons.list : Icons.grid_3x3),
            tooltip: 'Toggle View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search equipment...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Equipment List/Grid
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No equipment found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your search or filter',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final equipment = filteredItems[index];
                          return _buildEquipmentGridCard(context, equipment);
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final equipment = filteredItems[index];
                          return _buildEquipmentListCard(context, equipment);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentListCard(BuildContext context, Equipment equipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            equipment.icon,
            color: Colors.blue,
            size: 28,
          ),
        ),
        title: Text(
          equipment.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Chip(
              label: Text(equipment.category),
              backgroundColor: Colors.blue.withOpacity(0.2),
              labelStyle: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text(
              'Available: ${equipment.available}/${equipment.quantity}',
              style: TextStyle(
                color: equipment.available > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showEquipmentDetails(equipment),
      ),
    );
  }

  Widget _buildEquipmentGridCard(BuildContext context, Equipment equipment) {
    return GestureDetector(
      onTap: () => _showEquipmentDetails(equipment),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.05),
                Colors.blue.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      equipment.icon,
                      size: 32,
                      color: Colors.blue,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: equipment.available > 0 ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${equipment.available}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  equipment.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  equipment.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
