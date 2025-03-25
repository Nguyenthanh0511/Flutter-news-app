// Không cần loằng ngoằng như news nhé ( Cái đấy viết chỉ có dài và hiểu hơn abstract và mã hóa, giải mã json thôi)
// Lưu ý ở trên code đang là UserEntity tuy nhiên trên firebase là user ( Đối tên User -> UserEntity vì bị giống User của authentication )
class UserEntity{
  final String id;
  final String name;
  final String email;
  final int age;
  final String? role; // User và Admin
  final String phoneNumber;
  final String? address;
  final int? sex; // 1: nam, 2: nu, 3: Khac
  final String? avatarUrl;
  //
  final int? postCount;
  final int? followerCount;
  final int? followingCount;
  //
  UserEntity({required this.id, required this.email, required this.name, required this.age, this.role, required this.phoneNumber, this.address, this.sex, this.avatarUrl, this.postCount, this.followerCount, this.followingCount});
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name':name,
    'age': age,
    'role': role,
    'phoneNumber': phoneNumber,
    'address': address,
    'sex': sex,
    'email': email,
    'avatarUrl': avatarUrl,
    'postCount': postCount,
    'followerCount': followerCount,
    'followingCount': followingCount,
   };
  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    role: json['role'],
    phoneNumber: json['phoneNumber'],
    address: json['address'],
    sex: json['sex'],
    email: json['email'],
    avatarUrl: json['avatarUrl'],
    postCount: json['postCount'],
    followerCount: json['followerCount'],
    followingCount: json['followingCount'],
  );

   UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? role,
    String? phoneNumber,
    String? address,
    int? sex,
    String? avatarUrl,
    int? postCount,
    int? followerCount,
    int? followingCount,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      sex: sex ?? this.sex,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}