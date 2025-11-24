import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API endpoints and base URL configuration.
/// Update your `.env` BASE_URL to switch environments.
class Endpoints {
  Endpoints._();

  /// computed and normalized base URL from .env (BASE_URL).
  static final String baseUrl = _computeBaseUrl();

  /// Build a full Uri from a relative [path] (e.g. "/api/login").
  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  // Auth
  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String logout = '/api/logout';

  // Buildings
  static const String buildings = '/api/buildings';
  static String buildingById(int id) => '/api/buildings/$id';
  static String buildingsByLandlord(int landlordId) =>
      '/api/buildings/landlord/$landlordId';
  static const String buildingPicturesUpload = '/api/images/upload';

  // Dashboard / Home
  static const String dashboardSummary = '/api/dashboard/summary';
  static const String recentInvoices = '/api/invoices/recent';
  static const String notifications = '/api/notifications';
  static String notificationById(int id) => '/api/notifications/$id';
  static String notificationMarkRead(int id) => '/api/notifications/$id/read';
  static const String notificationsUnread = '/api/notifications/unread';
  static const String sendReminders = '/api/invoices/send-reminders';
  

  // Normalize and validate BASE_URL from environment
  static String _computeBaseUrl() {
    var url = (dotenv.env['BASE_URL'] ?? '').trim();
    if (url.isEmpty) {
      throw Exception('BASE_URL is not set. Add BASE_URL to your .env');
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    dev.log('[Endpoints] baseUrl=$url');
    return url;
  }
}
