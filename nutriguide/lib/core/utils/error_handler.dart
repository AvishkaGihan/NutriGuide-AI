/// Abstract base class for all domain failures/exceptions
abstract class Failure {
  final String message;
  const Failure(this.message);

  factory Failure.fromException(Object e) {
    // In a real app, parse ApiException vs NetworkException here
    return ServerFailure(e.toString().replaceAll('ApiException:', '').trim());
  }
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
