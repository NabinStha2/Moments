import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

const appId = "ea8b2f5a8acd452e88b5028f95ab55dd";

IO.Socket? socket;

List<CameraDescription>? cameras;
