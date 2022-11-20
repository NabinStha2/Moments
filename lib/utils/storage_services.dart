import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moment/development/console.dart';

class StorageServices {
  static FlutterSecureStorage? _storage;
  static TextEditingController _accountNameController = TextEditingController();
  static Map<String, String> _authStorageValues = {};

  static get storage => _storage;
  static get accountNameController => _accountNameController;

  static get rememberMe async => await _storage?.read(key: "rememberMe") ?? "false";
  static get email async => await _storage?.read(key: "email");
  static get name async => await _storage?.read(key: "name");
  static get imageUrl async => await _storage?.read(key: "imageUrl");
  static get id async => await _storage?.read(key: "id");
  static get token async => await _storage?.read(key: "token");

  static Map<String, String> get authStorageValues => _authStorageValues;

  static setAuthStorageValues(Map<String, String> value) {
    // consolelog("data");
    _authStorageValues = value;
  }

  static initStorage() {
    _storage = const FlutterSecureStorage();
    _accountNameController = TextEditingController(text: 'flutter_secure_storage_service');
  }

  static Future getStorage() async {
    return await _storage?.readAll(
      aOptions: const AndroidOptions(),
      iOptions: IOSOptions(
        accountName: _accountNameController.text.isEmpty ? null : _accountNameController.text,
      ),
    );
  }

  static Future writeStorage({required String key, String? value}) async {
    return await _storage?.write(
      key: key,
      value: value,
      aOptions: const AndroidOptions(),
      iOptions: IOSOptions(
        accountName: _accountNameController.text.isEmpty ? null : _accountNameController.text,
      ),
    );
  }

  static Future deleteAllStorage({String? key, dynamic value}) async {
    return await _storage?.deleteAll(
      aOptions: const AndroidOptions(),
      iOptions: IOSOptions(
        accountName: _accountNameController.text.isEmpty ? null : _accountNameController.text,
      ),
    );
  }

  static Future deleteSpecificStorage({String? key, dynamic value}) async {
    return await _storage?.delete(
      key: key ?? "",
      aOptions: const AndroidOptions(),
      iOptions: IOSOptions(
        accountName: _accountNameController.text.isEmpty ? null : _accountNameController.text,
      ),
    );
  }
}
