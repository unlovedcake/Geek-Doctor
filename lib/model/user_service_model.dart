class UserServiceProviderModel {
  String? uid;
  String? fullName;
  String? email;
  String? address;
  String? contactNumber;
  String? status;
  String? vaccinated;
  String? tokenId;
  Map? skills;
  Map? rating;
  double? highScoreRating;
  String? imageUrl = "";
  Map? position;
  double? distance;

  UserServiceProviderModel(
      {this.uid,
      this.fullName,
      this.email,
      this.address,
      this.contactNumber,
      this.status,
      this.vaccinated,
      this.tokenId,
      this.skills,
      this.rating,
      this.highScoreRating,
      this.imageUrl,
      this.position,
      this.distance});

  // receiving data from server
  factory UserServiceProviderModel.fromMap(map) {
    return UserServiceProviderModel(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      address: map['address'],
      contactNumber: map['contactNumber'],
      status: map['status'],
      vaccinated: map['vaccinated'],
      tokenId: map['tokenId'],
      skills: map['skills'],
      rating: map['rating'],
      highScoreRating: map['highScoreRating'],
      imageUrl: map['imageUrl'],
      position: map['position'],
      distance: map['distance'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'address': address,
      'contactNumber': contactNumber,
      'status': status,
      'vaccinated': vaccinated,
      'tokenId': tokenId,
      'skills': skills,
      'rating': rating,
      'highScoreRating': highScoreRating,
      'imageUrl': imageUrl,
      'position': position,
      'distance': distance,
    };
  }
}
