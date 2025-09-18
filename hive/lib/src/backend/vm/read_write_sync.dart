import 'dart:async';

/// Lock mechanism to ensure correct order of execution
class ReadWriteSync {
  Future _readTask = Future.value();

  Future _writeTask = Future.value();

  static const _timeout = Duration(seconds: 30);

  /// Run operation with read lock
  Future<T> syncRead<T>(Future<T> Function() task) async {
    final previousTask = _readTask;

    final completer = Completer<void>();
    _readTask = completer.future;

    await previousTask;
    final resultFuture = task().timeout(_timeout);
    // ignore: prefer_async_await
    resultFuture.then(completer.complete).catchError(completer.completeError).ignore();
    return resultFuture;
  }

  /// Run operation with write lock
  Future<T> syncWrite<T>(Future<T> Function() task) async {
    final previousTask = _writeTask;

    final completer = Completer<void>();
    _writeTask = completer.future;

    await previousTask;
    final resultFuture = task().timeout(_timeout);
    // ignore: prefer_async_await
    resultFuture.then(completer.complete).catchError(completer.completeError).ignore();
    return resultFuture;
  }

  /// Run operation with read and write lock
  Future<T> syncReadWrite<T>(Future<T> Function() task) async {
    final previousReadTask = _readTask;
    final previousWriteTask = _writeTask;

    final completer = Completer<void>();
    final future = completer.future;
    _readTask = future;
    _writeTask = future;

    await previousReadTask;
    await previousWriteTask;
    final resultFuture = task().timeout(_timeout);
    // ignore: prefer_async_await
    resultFuture.then(completer.complete).catchError(completer.completeError).ignore();
    return resultFuture;
  }
}
