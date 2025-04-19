import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Service for managing user information persistence
class UserInfoService {
  // Keys for SharedPreferences
  static const String _nameKey = 'user_name';
  static const String _countryCodeKey = 'user_country_code';

  /// Save the user's name to SharedPreferences
  Future<bool> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_nameKey, name);
    } catch (e) {
      log('Error saving user name: $e');
      return false;
    }
  }

  /// Save the user's country code to SharedPreferences
  Future<bool> saveUserCountry(String countryCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_countryCodeKey, countryCode);
    } catch (e) {
      log('Error saving user country: $e');
      return false;
    }
  }

  /// Save both user name and country in one call
  Future<bool> saveUserInfo({
    required String name,
    required String countryCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nameResult = await prefs.setString(_nameKey, name);
      final countryResult = await prefs.setString(_countryCodeKey, countryCode);
      return nameResult && countryResult;
    } catch (e) {
      log('Error saving user info: $e');
      return false;
    }
  }

  /// Get the user's name from SharedPreferences
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nameKey);
    } catch (e) {
      log('Error getting user name: $e');
      return null;
    }
  }

  /// Get the user's country code from SharedPreferences
  Future<String?> getUserCountry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_countryCodeKey);
    } catch (e) {
      log('Error getting user country: $e');
      return null;
    }
  }

  /// Check if user info has been saved
  Future<bool> hasUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_nameKey) && prefs.containsKey(_countryCodeKey);
    } catch (e) {
      log('Error checking user info: $e');
      return false;
    }
  }

  /// Clear all user info
  Future<bool> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_nameKey);
      await prefs.remove(_countryCodeKey);
      return true;
    } catch (e) {
      log('Error clearing user info: $e');
      return false;
    }
  }
}
