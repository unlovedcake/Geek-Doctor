class BookModel {
  String? id;
  String? tokenId;
  String? serviceNeed;
  String? dateToBook;
  String? startTime;
  String? endTime;
  String? clientAddress;
  String? status;
  Map? userModel;
  Map? userServiceModel;

  BookModel(
      {this.id,
      this.tokenId,
      this.serviceNeed,
      this.dateToBook,
      this.startTime,
      this.endTime,
      this.clientAddress,
      this.status,
      this.userModel,
      this.userServiceModel});

  // receiving data from server
  factory BookModel.fromMap(map) {
    return BookModel(
      id: map['id'],
      tokenId: map['tokenId'],
      serviceNeed: map['serviceNeed'],
      dateToBook: map['dateToBook'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      clientAddress: map['clientAddress'],
      status: map['status'],
      userModel: map['userModel'],
      userServiceModel: map['userServiceModel'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tokenId': tokenId,
      'serviceNeed': serviceNeed,
      'dateToBook': dateToBook,
      'startTime': startTime,
      'endTime': endTime,
      'clientAddress': clientAddress,
      'status': status,
      'userModel': userModel,
      'userServiceModel': userServiceModel,
    };
  }
}
