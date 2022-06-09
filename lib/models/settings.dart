class Settings {
  String? alias;
  String host;
  String gRPCPort;
  String macaroon;
  bool useTor;

  Settings(
    this.host,
    this.gRPCPort,
    this.macaroon,
    this.useTor,
  );
}
