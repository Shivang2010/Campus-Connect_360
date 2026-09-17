import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';
import '../controllers/marketplace_controller.dart';
import '../models/marketplace_model.dart';

class MarketplaceView extends StatelessWidget {
  const MarketplaceView({super.key});

  void _showAddProductSheet(BuildContext context, MarketplaceController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddProductBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketplaceController());
    final AuthController authController = Get.find<AuthController>();
    final String currentUid = authController.userModel.value?.uid ?? '';
    final bool isAdmin = authController.userModel.value?.role == 'Admin';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Marketplace', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Condition Filter Chips
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'New', 'Like New', 'Used - Good', 'Fair']
                          .map((cond) {
                        final isSelected =
                            controller.selectedCondition.value == cond;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cond),
                            selected: isSelected,
                            selectedColor: theme.primaryColor.withAlpha(40),
                            labelStyle: TextStyle(
                              color: isSelected ? theme.primaryColor : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedCondition.value = cond;
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product List Grid
          Expanded(
            child: Obx(() {
              final products = controller.filteredProducts;

              if (products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be the first to list an item for sale in your campus community.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final MarketplaceModel product = products[index];
                  final bool isSeller = product.sellerId == currentUid;
                  final bool isSold = product.status == 'Sold';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 0,
                    color: isSold ? Colors.grey.shade50 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isSold ? Colors.grey.shade200 : Colors.grey.shade100, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Optional Product Image from Firebase Storage
                        if (product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              product.imageUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSold ? Colors.grey.shade400 : Colors.green.shade600,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '₹${product.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isSold ? Colors.grey.shade200 : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          product.status.toUpperCase(),
                                          style: TextStyle(
                                            color: isSold ? Colors.grey.shade700 : Colors.blue.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          product.condition,
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      if (isSeller || isAdmin)
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isSold ? Icons.check_box : Icons.check_box_outline_blank,
                                                color: isSold ? Colors.grey : Colors.green.shade700,
                                              ),
                                              tooltip: 'Mark as Sold/Available',
                                              onPressed: () => controller.toggleProductStatus(product.id, product.status),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline,
                                                  color: Colors.red),
                                              onPressed: () {
                                                Get.defaultDialog(
                                                  title: 'Delete Product',
                                                  middleText:
                                                      'Remove this listing from the marketplace?',
                                                  textConfirm: 'Delete',
                                                  textCancel: 'Cancel',
                                                  confirmTextColor: Colors.white,
                                                  buttonColor: Colors.red,
                                                  onConfirm: () {
                                                    Get.back();
                                                    controller
                                                        .deleteProduct(product.id);
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                product.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: isSold ? TextDecoration.lineThrough : null,
                                  color: isSold ? Colors.grey : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product.description,
                                style: TextStyle(
                                  color: isSold ? Colors.grey : Colors.grey.shade800,
                                  fontSize: 14,
                                ),
                              ),
                              if (!isSeller && !isSold) ...[
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                    label: const Text('Chat with Seller'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green.shade800,
                                      side: BorderSide(color: Colors.green.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.toNamed(
                                        AppRoutes.chat,
                                        arguments: {
                                          'otherUserId': product.sellerId,
                                          'otherUserName': 'Seller',
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductSheet(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Sell Item'),
      ),
    );
  }
}

// Dedicated StatefulWidget for Add Product Bottom Sheet
class _AddProductBottomSheet extends StatefulWidget {
  final MarketplaceController controller;

  const _AddProductBottomSheet({required this.controller});

  @override
  State<_AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<_AddProductBottomSheet> {
  late final TextEditingController titleController;
  late final TextEditingController priceController;
  late final TextEditingController descriptionController;
  String selectedCondition = 'Used - Good';
  XFile? selectedImage;

  final List<String> conditions = [
    'New',
    'Like New',
    'Used - Good',
    'Fair',
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    priceController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final StorageService storageService = Get.put(StorageService());
    final XFile? image = await storageService.pickImage();
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sell an Item on Marketplace',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Image Selection Button / Preview
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: Icon(
                selectedImage != null
                    ? Icons.check_circle
                    : Icons.add_a_photo_outlined,
                color: selectedImage != null ? Colors.green : Colors.blue,
              ),
              label: Text(
                selectedImage != null
                    ? 'Image Selected (${selectedImage!.name})'
                    : 'Select Product Photo (Optional)',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Product Name (e.g. Engineering Physics Textbook)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (in ₹)',
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: conditions
                  .map((cond) => DropdownMenuItem(
                        value: cond,
                        child: Text(cond),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCondition = value);
                }
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description / Details',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.controller.isLoading.value
                      ? null
                      : () {
                          widget.controller.addProduct(
                            title: titleController.text,
                            priceText: priceController.text,
                            condition: selectedCondition,
                            description: descriptionController.text,
                            selectedImage: selectedImage,
                          );
                        },
                  child: widget.controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'List Item for Sale',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
