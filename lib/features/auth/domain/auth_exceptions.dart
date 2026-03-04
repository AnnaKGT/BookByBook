// login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

class InvalidCredentialsAuthException implements Exception {}

// registration exceptions
class WeakPasswordAuthException implements Exception {}

class InvalidEmaiAuthException implements Exception {}

class EmailInUseAuthException implements Exception {}

// generic exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
