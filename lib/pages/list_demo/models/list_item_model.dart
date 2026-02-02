/// 列表项数据模型
class ListItemModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int height; // 用于瀑布流布局的高度（像素）
  final String category;
  final DateTime createdAt;

  ListItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.height,
    required this.category,
    required this.createdAt,
  });

  /// 生成示例数据
  static List<ListItemModel> generateSampleData() {
    final now = DateTime.now();
    return [
      ListItemModel(
        id: '1',
        title: '美丽的风景',
        description: '这是一张展示自然风光的图片，包含了山川、河流和蓝天白云。',
        imageUrl: 'https://picsum.photos/400/300?random=1',
        height: 300,
        category: '风景',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ListItemModel(
        id: '2',
        title: '城市夜景',
        description: '繁华都市的夜晚，霓虹灯闪烁，车流如织。',
        imageUrl: 'https://picsum.photos/400/500?random=2',
        height: 500,
        category: '城市',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ListItemModel(
        id: '3',
        title: '自然生态',
        description: '展示大自然中的动植物，生态平衡的美好画面。',
        imageUrl: 'https://picsum.photos/400/400?random=3',
        height: 400,
        category: '自然',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ListItemModel(
        id: '4',
        title: '艺术创作',
        description: '充满创意和想象力的艺术作品，展现人类智慧的结晶。',
        imageUrl: 'https://picsum.photos/400/350?random=4',
        height: 350,
        category: '艺术',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      ListItemModel(
        id: '5',
        title: '科技前沿',
        description: '现代科技的发展，人工智能、机器人等前沿技术。',
        imageUrl: 'https://picsum.photos/400/450?random=5',
        height: 450,
        category: '科技',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      ListItemModel(
        id: '6',
        title: '美食诱惑',
        description: '色香味俱全的美食，让人垂涎欲滴。',
        imageUrl: 'https://picsum.photos/400/320?random=6',
        height: 320,
        category: '美食',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      ListItemModel(
        id: '7',
        title: '运动健身',
        description: '健康的生活方式，运动带来的活力和快乐。',
        imageUrl: 'https://picsum.photos/400/380?random=7',
        height: 380,
        category: '运动',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      ListItemModel(
        id: '8',
        title: '旅行探索',
        description: '探索未知的世界，发现生活中的美好。',
        imageUrl: 'https://picsum.photos/400/420?random=8',
        height: 420,
        category: '旅行',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      ListItemModel(
        id: '9',
        title: '音乐旋律',
        description: '美妙的音乐，触动心灵的旋律。',
        imageUrl: 'https://picsum.photos/400/360?random=9',
        height: 360,
        category: '音乐',
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      ListItemModel(
        id: '10',
        title: '阅读时光',
        description: '沉浸在书海中，享受阅读的乐趣。',
        imageUrl: 'https://picsum.photos/400/340?random=10',
        height: 340,
        category: '阅读',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      ListItemModel(
        id: '11',
        title: '建筑设计',
        description: '精美的建筑设计，展现人类文明的智慧。',
        imageUrl: 'https://picsum.photos/400/480?random=11',
        height: 480,
        category: '建筑',
        createdAt: now.subtract(const Duration(days: 11)),
      ),
      ListItemModel(
        id: '12',
        title: '时尚潮流',
        description: '时尚的设计，引领潮流的风格。',
        imageUrl: 'https://picsum.photos/400/310?random=12',
        height: 310,
        category: '时尚',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      ListItemModel(
        id: '13',
        title: '动物世界',
        description: '可爱的动物，展现大自然的多样性。',
        imageUrl: 'https://picsum.photos/400/390?random=13',
        height: 390,
        category: '动物',
        createdAt: now.subtract(const Duration(days: 13)),
      ),
      ListItemModel(
        id: '14',
        title: '花卉植物',
        description: '美丽的花朵，绽放生命的色彩。',
        imageUrl: 'https://picsum.photos/400/370?random=14',
        height: 370,
        category: '植物',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      ListItemModel(
        id: '15',
        title: '海洋世界',
        description: '神秘的海洋，探索未知的深海世界。',
        imageUrl: 'https://picsum.photos/400/440?random=15',
        height: 440,
        category: '海洋',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }
}
