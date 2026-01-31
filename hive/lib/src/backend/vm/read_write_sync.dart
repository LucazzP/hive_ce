import 'dart:async';

/// Lock mechanism to ensure correct order of execution
class ReadWriteSync {
  Future _readTask = Future.value();

  Future _writeTask = Future.value();

  static const _defaultReadTimeout = Duration(seconds: 60);
  static const _defaultWriteTimeout = Duration(seconds: 60);
  static const _defaultReadWriteTimeout = Duration(seconds: 60);

  /// Run operation with read lock
  Future<T> syncRead<T>(Future<T> Function() task, {Duration timeout = _defaultReadTimeout}) async {
    final previousTask = _readTask;

    final completer = Completer<void>();
    _readTask = completer.future;

    await previousTask;
    final resultFuture = task().timeout(timeout);
    // ignore: prefer_async_await
    resultFuture.then((_) => completer.complete()).catchError((_) => completer.complete()).ignore();
    return resultFuture;
  }

  /// Run operation with write lock
  Future<T> syncWrite<T>(Future<T> Function() task, {Duration timeout = _defaultWriteTimeout}) async {
    final previousTask = _writeTask;

    final completer = Completer<void>();
    _writeTask = completer.future;

    await previousTask;
    final resultFuture = task().timeout(timeout);
    // ignore: prefer_async_await
    resultFuture.then((_) => completer.complete()).catchError((_) => completer.complete()).ignore();
    return resultFuture;
  }

  /// Run operation with read and write lock
  Future<T> syncReadWrite<T>(Future<T> Function() task, {Duration timeout = _defaultReadWriteTimeout}) async {
    final previousReadTask = _readTask;
    final previousWriteTask = _writeTask;

    final completer = Completer<void>();
    final future = completer.future;
    _readTask = future;
    _writeTask = future;

    await previousReadTask;
    await previousWriteTask;
    final resultFuture = task().timeout(timeout);
    // ignore: prefer_async_await
    resultFuture.then((_) => completer.complete()).catchError((_) => completer.complete()).ignore();
    return resultFuture;
  }
}
