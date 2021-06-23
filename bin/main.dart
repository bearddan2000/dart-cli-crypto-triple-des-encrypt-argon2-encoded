import 'package:dargon2/dargon2.dart';
import 'package:convert/convert.dart';
import 'package:dart_des/dart_des.dart';
import 'dart:convert';

final s = Salt.newSalt();
String key = '123456781234567812345678'; // 24-byte
List<int> iv = [1, 2, 3, 4, 5, 6, 7, 8];

encrypt(psw) {
  DES3 des3CBC = DES3(key: key.codeUnits, mode: DESMode.CBC, iv: iv);
  List<int> encrypted = des3CBC.encrypt(psw.codeUnits);
  return base64.encode(encrypted);
}

Future<bool> verify(psw1, psw2, hashed) async {
  print("[VERIFY] $psw1\t$psw2");
  psw1 = encrypt(psw1);
  try {
   await argon2.verifyHashString(psw1, hashed);
   return true;
   } on Exception {
    return false;
   }
}

Future<String> hash(psw) async {
  print("[HASH] plainPassword: $psw");
  psw = encrypt(psw);
  var result = await argon2.hashPasswordString(psw, salt: s);
  String hashed = result.encodedString;
  print("[HASH] hashedPassword: $hashed");
  return hashed;
}

main() async {
  String psw1 = "pass1234";
  String psw2 = "1234pass";
  String hash1 = await hash(psw1);
  String hash2 = await hash(psw2);
  bool first = await verify(psw1, psw2, hash2);
  print("[VERIFY] $first");
  bool second = await verify(psw1, psw1, hash1);
  print("[VERIFY] $second");
}
