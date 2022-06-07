class FutureTesting {
  //* Used for testing the progress bar
  static Future<bool> delayFuture(Duration duration) async {
    await Future.delayed(duration).then((onValue) => true);
    return true;
  }
}
