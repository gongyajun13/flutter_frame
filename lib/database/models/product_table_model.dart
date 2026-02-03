/// 产品表模型
/// 对应数据库 products 表
class ProductTableModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final String category;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductTableModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    required this.category,
    this.stock = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从数据库 Map 创建
  factory ProductTableModel.fromMap(Map<String, dynamic> map) {
    return ProductTableModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String?,
      category: map['category'] as String,
      stock: map['stock'] as int,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'stock': stock,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 从 JSON 创建（用于网络数据）
  factory ProductTableModel.fromJson(Map<String, dynamic> json) {
    return ProductTableModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String?,
      category: json['category'] as String,
      stock: json['stock'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
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

  /// 复制并更新
  ProductTableModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? category,
    int? stock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductTableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductTableModel{id: $id, name: $name, price: $price, category: $category}';
  }
}
