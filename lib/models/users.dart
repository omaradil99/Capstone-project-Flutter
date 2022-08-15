class Users {
  final String id;
  final String userName;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String major;
  final String birthDate;
  final String gender;
  final String fieldOfStudy;
  final String imageUrl;
  final String transcriptUrl;
  final String resumeUrl;

  Users({
    required this.id,
    required this.userName,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.major,
    required this.birthDate,
    required this.gender,
    required this.fieldOfStudy,
    required this.imageUrl,
    required this.transcriptUrl,
    required this.resumeUrl
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': userName,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'major': major,
        'birthDate' : birthDate,
        'gender' : gender,
        'fieldOfStudy' :fieldOfStudy,
        'imageUrl' : imageUrl,
        'transcriptUrl' : transcriptUrl,
        'resumeUrl' : resumeUrl
      };

  
  static Users fromJson(Map<String, dynamic> json) => Users(
        fieldOfStudy: json['fieldOfStudy'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        gender: json['gender'],
        major: json['major'],
        resumeUrl: json['resumeUrl'],
        transcriptUrl: json['transcriptUrl'],
        id: json['id'],
        imageUrl: json['imageUrl'],
        email: json['email'],
        password: json['password'],
        userName: json['username'],
        birthDate: json['birthDate'],
      );
}
