//@dart=2.1

class FriendRequestModel {
  int id;
  int status;
  String createdAt;
  User1 user1;
  User1 user2;

  FriendRequestModel(
      {this.id, this.status, this.createdAt, this.user1, this.user2});

  FriendRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    createdAt = json['createdAt'];
    user1 = json['user1'] != null ? new User1.fromJson(json['user1']) : null;
    user2 = json['user2'] != null ? new User1.fromJson(json['user2']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    if (this.user1 != null) {
      data['user1'] = this.user1.toJson();
    }
    if (this.user2 != null) {
      data['user2'] = this.user2.toJson();
    }
    return data;
  }
}

class User1 {
  int id;
  String firstName;
  String lastName;
  String city;
  bool agreeToTerms;
  bool calculateHealthScore;
  bool useCookiesSDKs;
  Null birthDate;
  Null height;
  Null weight;
  String gender;
  String email;
  String zipCode;
  String mobileNumber;
  String password;
  bool isVerified;
  bool isActive;
  String pedometerUserId;
  String selectedPedometer;
  String createdAt;
  String updatedAt;
  String fullName;

  User1(
      {this.id,
      this.firstName,
      this.lastName,
      this.city,
      this.agreeToTerms,
      this.calculateHealthScore,
      this.useCookiesSDKs,
      this.birthDate,
      this.height,
      this.weight,
      this.gender,
      this.email,
      this.zipCode,
      this.mobileNumber,
      this.password,
      this.isVerified,
      this.isActive,
      this.pedometerUserId,
      this.selectedPedometer,
      this.createdAt,
      this.updatedAt,
      this.fullName});

  User1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    city = json['city'];
    agreeToTerms = json['agreeToTerms'];
    calculateHealthScore = json['calculateHealthScore'];
    useCookiesSDKs = json['useCookiesSDKs'];
    birthDate = json['birthDate'];
    height = json['height'];
    weight = json['weight'];
    gender = json['gender'];
    email = json['email'];
    zipCode = json['zipCode'];
    mobileNumber = json['mobileNumber'];
    password = json['password'];
    isVerified = json['isVerified'];
    isActive = json['isActive'];
    pedometerUserId = json['pedometerUserId'];
    selectedPedometer = json['selectedPedometer'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    fullName = json['fullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['city'] = this.city;
    data['agreeToTerms'] = this.agreeToTerms;
    data['calculateHealthScore'] = this.calculateHealthScore;
    data['useCookiesSDKs'] = this.useCookiesSDKs;
    data['birthDate'] = this.birthDate;
    data['height'] = this.height;
    data['weight'] = this.weight;
    data['gender'] = this.gender;
    data['email'] = this.email;
    data['zipCode'] = this.zipCode;
    data['mobileNumber'] = this.mobileNumber;
    data['password'] = this.password;
    data['isVerified'] = this.isVerified;
    data['isActive'] = this.isActive;
    data['pedometerUserId'] = this.pedometerUserId;
    data['selectedPedometer'] = this.selectedPedometer;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['fullName'] = this.fullName;
    return data;
  }
}
