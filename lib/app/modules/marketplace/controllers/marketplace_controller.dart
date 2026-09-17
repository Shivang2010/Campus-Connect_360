import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/storage_service.dart';
import '../models/marketplace_model.dart';

class MarketplaceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive list of all marketplace products
  RxList<MarketplaceModel> productList = <MarketplaceModel>[].obs;

  // Reactive filter and search states
  RxString searchQuery = ''.obs;
  RxString selectedCondition = 'All'.obs;

  // Loading state for product submission
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    productList.bindStream(
      _firestore
          .collection('marketplace')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => MarketplaceModel.fromJson(doc.data(), doc.id))
                .toList(),
          ),
    );
  }

  // Filter products by keyword search and condition filter
  List<MarketplaceModel> get filteredProducts {
    return productList.where((product) {
      final matchesSearch = product.title
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          product.description
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      final matchesCondition = selectedCondition.value == 'All' ||
          product.condition == selectedCondition.value;

      return matchesSearch && matchesCondition;
    }).toList();
  }

  // Add a new product to Marketplace with optional Firebase Storage image upload
  Future<void> addProduct({
    required String title,
    required String description,
    required String priceText,
    required String condition,
    XFile? selectedImage,
  }) async {
    if (title.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a product title');
      return;
    }

    final double? parsedPrice = double.tryParse(priceText.trim());
    if (parsedPrice == null || parsedPrice <= 0) {
      Get.snackbar('Validation Error', 'Please enter a valid price');
      return;
    }

    if (description.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a product description');
      return;
    }

    final AuthController authController = Get.find<AuthController>();
    final String? uid = authController.userModel.value?.uid;

    if (uid == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      isLoading.value = true;

      final DocumentReference docRef =
          _firestore.collection('marketplace').doc();
      String? imageUrl;

      // Upload image to Firebase Storage if selected
      if (selectedImage != null) {
        final StorageService storageService = Get.put(StorageService());
        imageUrl = await storageService.uploadMarketplaceImage(
          itemId: docRef.id,
          imageFile: selectedImage,
        );
      }

      MarketplaceModel newProduct = MarketplaceModel(
        id: docRef.id,
        title: title.trim(),
        description: description.trim(),
        price: parsedPrice,
        condition: condition,
        sellerId: uid,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        status: 'Available',
      );

      await docRef.set(newProduct.toJson());

      Get.back(); // Close modal sheet
      Get.snackbar(
        'Success',
        'Product listed successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not list product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete product listing (seller or admin)
  Future<void> deleteProduct(String docId) async {
    try {
      await _firestore.collection('marketplace').doc(docId).delete();
      Get.snackbar(
        'Success',
        'Product removed from marketplace',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not delete product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Toggle item availability status between 'Available' and 'Sold'
  Future<void> toggleProductStatus(String docId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'Available' ? 'Sold' : 'Available';
      await _firestore.collection('marketplace').doc(docId).update({
        'status': newStatus,
      });
      Get.snackbar(
        'Status Updated',
        'Product marked as $newStatus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not update status: $e');
    }
  }
}
