/// Абстрактный класс для представления ошибок в приложении.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Ошибка, связанная с локальным хранилищем (например, Hive).
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}