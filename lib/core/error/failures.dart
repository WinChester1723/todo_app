/// Абстрактный класс для представления ошибок в приложении.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Ошибка, связанная с локальным хранилищем (например, Hive).
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Ошибка, связанная с удалённым хранилищем (например, сетью).
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}

/// Ошибка, связанная с сетью (например, отсутствие подключения к интернету).
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}
