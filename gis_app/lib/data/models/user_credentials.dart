class UserCredentials {
  final int id;
  final String salt;
  final String hashPassword;

  UserCredentials({required this.id, required this.salt, required this.hashPassword});
}