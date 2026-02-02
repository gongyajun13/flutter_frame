/// 省份模型
class ProvinceModel {
  final String name;
  final List<CityModel> city;

  ProvinceModel({
    required this.name,
    required this.city,
  });

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      name: json['name'] as String,
      city: (json['city'] as List<dynamic>)
          .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 城市模型
class CityModel {
  final String name;
  final List<String> area;

  CityModel({
    required this.name,
    required this.area,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      area: (json['area'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}

/// 选中的省市区信息
class SelectedRegion {
  final String province;
  final String city;
  final String area;

  SelectedRegion({
    required this.province,
    required this.city,
    required this.area,
  });

  String get fullAddress => '$province $city $area';

  @override
  String toString() => fullAddress;
}
