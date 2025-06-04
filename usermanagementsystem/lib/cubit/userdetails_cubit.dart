import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserDetailsCubit extends Cubit<Map<String, dynamic>?> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final String _storageKey = "user_details";

  UserDetailsCubit() : super(null) {
    _loadData();
  }

  
  Future<void> _loadData() async {
    String? storedData = await _storage.read(key: _storageKey);
    if (storedData != null) {
      emit(jsonDecode(storedData)); 
    }else{
      emit(null);
    }
  }

  Future<void> updateData(Map<String, dynamic> newData) async {
    await _storage.write(key: _storageKey, value: jsonEncode(newData));
    emit(newData); 
  }
  
  Future<void> clearData() async {
    await _storage.delete(key: _storageKey);
    emit(null); 
  }
}
