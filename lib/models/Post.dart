class Post {
  final String id;
  final String description;
  final String validUntil;
  final String availableFor;
  final String imageUrl;
  final String owner;
  final String ownerEmail;

  Post({
    required this.id,
    required this.description,
    required this.validUntil,
    required this.availableFor,
    required this.imageUrl,
    required this.owner,
    required this.ownerEmail
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'validUntil': validUntil,
        'availableFor': availableFor,
        'imageUrl': imageUrl,
        'owner': owner,
        'ownerEmail': ownerEmail
      };

  static Post fromJson(Map<String, dynamic> json) => Post(
        id: json['id'],
        description: json['description'],
        validUntil: json['validUntil'],
        availableFor: json['availableFor'],
        imageUrl: json['imageUrl'],
        owner: json['owner'],
        ownerEmail: json['ownerEmail']
      );
}
