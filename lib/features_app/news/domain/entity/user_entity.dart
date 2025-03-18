// Không cần loằng ngoằng như news nhé ( Cái đấy viết chỉ có dài và hiểu hơn abstract và mã hóa, giải mã json thôi)

class User{
  final String id;
  final String name;
  final int age;
  final String role; // User và Admin

  User({required this.id, required this.name, required this.age, required this.role});
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name':name,
    'age': age,
    'role': role
  };
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    role: json['role']
  );

}