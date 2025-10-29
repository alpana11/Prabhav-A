class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  String? _username;
  String? _governmentIdType;
  String? _governmentIdNumber;

  // Getters
  String? get username => _username;
  String? get governmentIdType => _governmentIdType;
  String? get governmentIdNumber => _governmentIdNumber;

  bool get isLoggedIn => _username != null;

  // Setters
  void setUserData({
    required String username,
    required String governmentIdType,
    required String governmentIdNumber,
  }) {
    _username = username;
    _governmentIdType = governmentIdType;
    _governmentIdNumber = governmentIdNumber;
  }

  void clearUserData() {
    _username = null;
    _governmentIdType = null;
    _governmentIdNumber = null;
  }

  Map<String, dynamic> toMap() {
    return {
      'username': _username,
      'governmentIdType': _governmentIdType,
      'governmentIdNumber': _governmentIdNumber,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    _username = map['username'];
    _governmentIdType = map['governmentIdType'];
    _governmentIdNumber = map['governmentIdNumber'];
  }
}

