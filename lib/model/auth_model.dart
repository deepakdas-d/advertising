class AuthModel {
  final String accessToken;
  final String refreshToken;

  AuthModel({required this.accessToken, required this.refreshToken});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['access'] ?? '', // match server key
      refreshToken: json['refresh'] ?? '', // match server key
    );
  }

  Map<String, dynamic> toJson() {
    return {'access': accessToken, 'refresh': refreshToken};
  }
}
