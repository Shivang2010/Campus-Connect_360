import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect_360/app/modules/marketplace/models/marketplace_model.dart';

void main() {
  group('MarketplaceModel Unit Tests', () {
    test('toJson and fromJson work cleanly', () {
      final now = DateTime.now();
      final product = MarketplaceModel(
        id: 'prod_99',
        title: 'Scientific Calculator',
        description: 'Casio fx-991EX in excellent condition',
        price: 850.0,
        condition: 'Like New',
        sellerId: 'user_123',
        createdAt: now,
        status: 'Available',
      );

      final json = product.toJson();
      expect(json['title'], 'Scientific Calculator');
      expect(json['price'], 850.0);
      expect(json['condition'], 'Like New');
      expect(json['sellerId'], 'user_123');

      final reconstructed = MarketplaceModel.fromJson(json, 'prod_99');
      expect(reconstructed.id, 'prod_99');
      expect(reconstructed.price, 850.0);
    });
  });
}
