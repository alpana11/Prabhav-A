class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  String? _username;
  String? _governmentIdType;
  String? _governmentIdNumber;
  String? _email;
  String? _phone;
  String? _location;
  String? _avatar;
  int _complaintCount = 0;
  List<Map<String, dynamic>> _complaints = [];

  // Getters
  String? get username => _username;
  String? get governmentIdType => _governmentIdType;
  String? get governmentIdNumber => _governmentIdNumber;
  String? get email => _email;
  String? get phone => _phone;
  String? get location => _location;
  String? get avatar => _avatar;
  int get complaintCount => _complaintCount;
  List<Map<String, dynamic>> get complaints => _complaints;

  bool get isLoggedIn => _username != null;

  // Setters
  void setUserData({
    required String username,
    required String governmentIdType,
    required String governmentIdNumber,
    String? email,
    String? phone,
    String? location,
    String? avatar,
    int complaintCount = 0,
    List<Map<String, dynamic>>? complaints,
  }) {
    _username = username;
    _governmentIdType = governmentIdType;
    _governmentIdNumber = governmentIdNumber;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (location != null) _location = location;
    if (avatar != null) _avatar = avatar;
    _complaintCount = complaintCount;
    if (complaints != null) _complaints = complaints;
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

