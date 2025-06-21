import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_ambw/models/auth_user.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Current user
  static AppUser? _currentUser;
  static AppUser? get currentUser => _currentUser;

  // Stream of auth changes
  static Stream<AuthState> get authStateChanges => 
      _client.auth.onAuthStateChange;

  // Initialize and check logged in user
  static Future<AppUser?> initialize() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      try {
        _currentUser = await _getUserProfile(user.id);
        return _currentUser;
      } catch (e) {
        debugPrint('Error fetching user profile: $e');
        return null;
      }
    }
    return null;
  }
  // Sign up with email and password
  static Future<AppUser?> signUp({
    required String email, 
    required String password,
    required String name,
    int? noHp, // no_hp sekarang int
    String? gender, // gender varchar
    DateTime? tanggalLahir, // tanggal_lahir date
  }) async {
    try {
      // Sign up the user with Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'no_hp': noHp,
          'gender': gender,
          'tanggal_lahir': tanggalLahir != null ? tanggalLahir.toIso8601String().split('T')[0] : null,
        },
        emailRedirectTo: null, // Prevent email confirmation redirect
      );
      
      if (response.user != null) {
        // Langsung login setelah sign up, tidak perlu konfirmasi email
        // (ini hanya untuk development, di production seharusnya menggunakan konfirmasi email)
        try {
          await _client.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } catch (loginError) {
          debugPrint('Error auto login after signup: $loginError');
          // Continue anyway
        }
        
        // Manually insert the user into the users table
        try {
          await _client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'name': name,
            'no_hp': noHp,
            'gender': gender,
            'tanggal_lahir': tanggalLahir != null ? tanggalLahir.toIso8601String().split('T')[0] : null,
          });
        } catch (insertError) {
          debugPrint('Error inserting user into users table: $insertError');
          // Continue even if insert fails, as it might be a duplicate key error
        }
        
        _currentUser = AppUser(
          id: response.user!.id,
          email: email,
          name: name,
          noHp: noHp,
          gender: gender,
          tanggalLahir: tanggalLahir,
        );
        
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Error in signUp: $e');
      rethrow;
    }
    
    return null;
  }// Sign in with email and password
  static Future<AppUser?> signIn({
    required String email, 
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        try {
          // Try to get user profile
          _currentUser = await _getUserProfile(response.user!.id);
        } catch (e) {
          debugPrint('Error getting user profile: $e');
          // If profile doesn't exist, create one
          int? parsedNoHp;
          final rawNoHp = response.user!.userMetadata?['no_hp'];
          if (rawNoHp is int) {
            parsedNoHp = rawNoHp;
          } else if (rawNoHp is String) {
            parsedNoHp = int.tryParse(rawNoHp);
          }
          try {
            await _client.from('users').insert({
              'id': response.user!.id,
              'email': email,
              'name': response.user!.userMetadata?['name'] ?? email.split('@').first,
              'no_hp': parsedNoHp,
              'gender': response.user!.userMetadata?['gender'],
              'tanggal_lahir': response.user!.userMetadata?['tanggal_lahir'],
            });
            // Create AppUser object
            _currentUser = AppUser(
              id: response.user!.id,
              email: email,
              name: response.user!.userMetadata?['name'] ?? email.split('@').first,
              noHp: parsedNoHp,
              gender: response.user!.userMetadata?['gender'],
              tanggalLahir: (() {
                final tgl = response.user!.userMetadata?['tanggal_lahir'];
                if (tgl != null && tgl.toString().isNotEmpty) {
                  return DateTime.tryParse(tgl);
                }
                return null;
              })(),
            );
          } catch (insertError) {
            debugPrint('Error creating user profile: $insertError');
            // Create AppUser object anyway
            _currentUser = AppUser(
              id: response.user!.id,
              email: email,
              name: response.user!.userMetadata?['name'] ?? email.split('@').first,
              noHp: parsedNoHp,
              gender: response.user!.userMetadata?['gender'],
              tanggalLahir: (() {
                final tgl = response.user!.userMetadata?['tanggal_lahir'];
                if (tgl != null && tgl.toString().isNotEmpty) {
                  return DateTime.tryParse(tgl);
                }
                return null;
              })(),
            );
          }
        }
        
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Error in signIn: $e');
      rethrow;
    }
    
    return null;
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
    _currentUser = null;
  }
  // Fetch user profile from database
  static Future<AppUser?> _getUserProfile(String userId) async {
    try {
      // Try to get user profile from users table
      final userData = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return AppUser.fromJson({
        ...userData,
        'id': userId,
      });
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      
      // If user doesn't have a profile yet, create one
      final user = _client.auth.currentUser;
      if (user != null) {
        int? noHp;
        final rawNoHp = user.userMetadata?['no_hp'];
        if (rawNoHp is int) {
          noHp = rawNoHp;
        } else if (rawNoHp is String) {
          noHp = int.tryParse(rawNoHp);
        }
        final data = {
          'id': user.id,
          'email': user.email,
          'name': user.userMetadata?['name'] ?? user.email?.split('@').first,
          'no_hp': noHp,
          'gender': user.userMetadata?['gender'],
          'tanggal_lahir': user.userMetadata?['tanggal_lahir'],
        };
        
        // Try to create user profile
        try {
          await _client.from('users').insert(data);
          return AppUser.fromJson(data);
        } catch (insertError) {
          debugPrint('Error creating user profile: $insertError');
          // Return the user data anyway
          return AppUser.fromJson(data);
        }
      }
    }
    return null;
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Update user profile (tambahan gender, tanggalLahir, email)
  static Future<AppUser?> updateUserProfile({
    String? name,
    String? photoUrl,
    int? noHp,
    String? gender,
    DateTime? tanggalLahir,
    String? email,
  }) async {
    if (_currentUser == null) return null;
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (noHp != null) updates['no_hp'] = noHp;
      if (gender != null) updates['gender'] = gender;
      if (tanggalLahir != null) updates['tanggal_lahir'] = tanggalLahir.toIso8601String().split('T')[0];
      if (email != null && email != _currentUser!.email) updates['email'] = email;
      if (updates.isNotEmpty) {
        await _client.from('users').update(updates).eq('id', _currentUser!.id);
        _currentUser = AppUser(
          id: _currentUser!.id,
          email: email ?? _currentUser!.email,
          name: name ?? _currentUser!.name,
          photoUrl: photoUrl ?? _currentUser!.photoUrl,
          noHp: noHp ?? _currentUser!.noHp,
          gender: gender ?? _currentUser!.gender,
          tanggalLahir: tanggalLahir ?? _currentUser!.tanggalLahir,
        );
      }
      return _currentUser;
    } catch (e) {
      rethrow;
    }
  }

  // Delete account
  static Future<void> deleteAccount(BuildContext context) async {
    if (_currentUser == null) return;
    try {
      // Hapus dari tabel users
      await _client.from('users').delete().eq('id', _currentUser!.id);
      // Sign out user
      await signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus akun: ${e.toString()}')),
      );
      rethrow;
    }
  }
}
