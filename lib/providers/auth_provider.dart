import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In 임포트

// AuthProvider manages user authentication state and interactions with the backend.
class AuthProvider with ChangeNotifier {
  // Secure storage for JWT token
  final _storage = const FlutterSecureStorage();
  String? _token; // Stores the JWT token
  String? _refreshToken; // Stores the refresh token
  User? _firebaseUser; // Stores the current Firebase user

  // Firebase Auth 인스턴스
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Google Sign-In 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Getter for the current JWT token
  String? get token => _token;
  User? get firebaseUser => _firebaseUser;

  // Base URL for the Kotlin Auth Service API
  static const String _authServiceBaseUrl = 'http://localhost:8080/auth'; // Gateway를 통한 Auth Service 경로

  // Handles user login by sending credentials to Firebase and then to our backend.
  Future<void> login(String email, String password) async {
    try {
      // 1. Firebase에 이메일/비밀번호로 로그인
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = userCredential.user;

      if (_firebaseUser != null) {
        // 2. Firebase ID Token 가져오기
        final firebaseIdToken = await _firebaseUser!.getIdToken();

        // 3. Firebase ID Token을 Kotlin 인증 서비스로 전송하여 내부 JWT 발급받기
        final url = Uri.parse('$_authServiceBaseUrl/firebase-login');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'firebaseIdToken': firebaseIdToken}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          _token = responseData['accessToken'];
          _refreshToken = responseData['refreshToken'];

          // Store the tokens securely
          await _storage.write(key: 'jwt_token', value: _token);
          await _storage.write(key: 'refresh_token', value: _refreshToken);
          notifyListeners();
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['detail'] ?? '백엔드 로그인 실패');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 오류 처리
      throw Exception(e.message ?? 'Firebase 로그인 실패');
    } catch (error) {
      rethrow; // Re-throw any other errors
    }
  }

  // Handles user signup by sending registration details to Firebase and then to our backend.
  Future<void> signup(String email, String password, String? nickname) async {
    try {
      // 1. Firebase에 이메일/비밀번호로 회원가입
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = userCredential.user;

      if (_firebaseUser != null) {
        // 2. 회원가입 성공 후, 로그인 함수를 호출하여 내부 JWT 발급받기
        await login(email, password); // login 함수 내에서 Firebase ID Token 처리 및 백엔드 통신
      }
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 오류 처리
      throw Exception(e.message ?? 'Firebase 회원가입 실패');
    } catch (error) {
      rethrow;
    }
  }

  // Handles Google Sign-In.
  Future<void> signInWithGoogle() async {
    try {
      // 1. Google 로그인 팝업 띄우기
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // 2. Google 인증 정보 가져오기
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // 3. Firebase에 Google 자격 증명으로 로그인
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        _firebaseUser = userCredential.user;

        if (_firebaseUser != null) {
          // 4. Firebase ID Token 가져오기 및 백엔드로 전송
          final firebaseIdToken = await _firebaseUser!.getIdToken();
          final url = Uri.parse('$_authServiceBaseUrl/firebase-login');
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'firebaseIdToken': firebaseIdToken}),
          );

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            _token = responseData['accessToken'];
            _refreshToken = responseData['refreshToken'];
            await _storage.write(key: 'jwt_token', value: _token);
            await _storage.write(key: 'refresh_token', value: _refreshToken);
            notifyListeners();
          } else {
            final errorData = json.decode(response.body);
            throw Exception(errorData['detail'] ?? '백엔드 로그인 실패');
          }
        }
      } else {
        // Google 로그인 취소
        throw Exception('Google 로그인 취소');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Firebase Google 로그인 실패');
    } catch (error) {
      rethrow;
    }
  }

  // Logs out the user by clearing the token from memory and secure storage, and Firebase.
  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _firebaseUser = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
    await _firebaseAuth.signOut(); // Firebase에서 로그아웃
    await _googleSignIn.signOut(); // Google에서 로그아웃
    notifyListeners();
  }

  // Attempts to automatically log in the user using a stored JWT token.
  Future<void> autoLogin() async {
    _token = await _storage.read(key: 'jwt_token');
    _refreshToken = await _storage.read(key: 'refresh_token');

    if (_token != null && _refreshToken != null) {
      // Firebase 로그인 상태 확인 (선택 사항: 필요에 따라 Firebase 재인증 로직 추가 가능)
      _firebaseUser = _firebaseAuth.currentUser;
      if (_firebaseUser == null) {
        // Firebase 사용자 정보가 없으면, Refresh Token을 사용하여 Access Token 재발급 시도
        // 이 부분은 Kotlin 인증 서비스에 refresh-token 엔드포인트가 구현된 후 추가
        // 현재는 Firebase 사용자 정보가 없으면 로그인 실패로 간주
        _token = null;
        _refreshToken = null;
        await _storage.delete(key: 'jwt_token');
        await _storage.delete(key: 'refresh_token');
        notifyListeners();
        return;
      }
      notifyListeners();
    } else {
      _token = null;
      _refreshToken = null;
      await _storage.delete(key: 'jwt_token');
      await _storage.delete(key: 'refresh_token');
      notifyListeners();
    }
  }
}
