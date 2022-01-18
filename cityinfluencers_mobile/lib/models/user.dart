class User {
  int id;
  String userName;
  String firstName;
  String name;
  String adress;
  String password;
  String birthDate;
  String email;
  String gender;

  User({required this.id, required this.userName, required this.firstName, required this.name, required this.adress, required this.password, required this.birthDate, required this.email, required this.gender});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      firstName: json['firstName'],
      name: json['name'],
      adress: json['adress'],
      password: json['password'],
      birthDate: json ['birthDate'],
      email: json['email'],
      gender: json['gender'],
      
    );
  }

  Map<String, dynamic> toJson() => {'userName': userName, 'firstName': firstName, 'name': name, 'adress': adress, 'password': password, 'birthDate': birthDate, 'email': email, 'gender': gender};
}