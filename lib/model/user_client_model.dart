class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? address;
  String? contactNumber;
  String? status;
  String? tokenId;
  String? imageUrl = "";

  UserModel(
      {this.uid,
      this.fullName,
      this.email,
      this.address,
      this.contactNumber,
      this.status,
      this.tokenId,
      this.imageUrl});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      address: map['address'],
      contactNumber: map['contactNumber'],
      status: map['status'],
      tokenId: map['tokenId'],
      imageUrl: map['imageUrl'],
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
      'tokenId': tokenId,
      'imageUrl': imageUrl,
    };
  }
}
