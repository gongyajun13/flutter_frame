/// 产品模型
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String category;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.category,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON创建产品模型
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'],
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'stock': stock,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ProductModel{id: $id, name: $name, price: $price, category: $category}';
  }
}

/// 创建产品请求模型
class CreateProductRequestModel {
  final String name;
  final String description;
  final double price;
  final String? image;
  final String category;
  final int stock;

  CreateProductRequestModel({
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.category,
    required this.stock,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'stock': stock,
    };
  }
}

/// 更新产品请求模型
class UpdateProductRequestModel {
  final String? name;
  final String? description;
  final double? price;
  final String? image;
  final String? category;
  final int? stock;
  final bool? isActive;

  UpdateProductRequestModel({
    this.name,
    this.description,
    this.price,
    this.image,
    this.category,
    this.stock,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (price != null) json['price'] = price;
    if (image != null) json['image'] = image;
    if (category != null) json['category'] = category;
    if (stock != null) json['stock'] = stock;
    if (isActive != null) json['isActive'] = isActive;
    return json;
  }
}
