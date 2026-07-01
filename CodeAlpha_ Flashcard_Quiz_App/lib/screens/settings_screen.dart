import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnightPurple,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildSectionHeader('PREFERENCES'),
            _buildSwitchTile(
              'Push Notifications',
              'Daily study reminders',
              Icons.notifications_active,
              _notificationsEnabled,
              (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildSwitchTile(
              'Dark Mode',
              'Use dark theme (Default)',
              Icons.dark_mode,
              _darkMode,
              (val) => setState(() => _darkMode = val),
            ),
            _buildSwitchTile(
              'Offline Mode',
              'Download decks for offline study',
              Icons.offline_bolt,
              _offlineMode,
              (val) => setState(() => _offlineMode = val),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('SUPPORT & ABOUT'),
            _buildListTile('Help Center', Icons.help_outline, () {}),
            _buildListTile('Privacy Policy', Icons.privacy_tip_outlined, () {}),
            _buildListTile('About EduFlip', Icons.info_outline, () {
              showAboutDialog(
                context: context,
                applicationName: 'EduFlip',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.style, color: AppTheme.primaryBlue, size: 40),
                applicationLegalese: '© 2026 EduFlip Inc. All rights reserved.',
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.glassDecoration.copyWith(
        color: Colors.white.withOpacity(0.05),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        secondary: Icon(icon, color: AppTheme.primaryBlue),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
        activeTrackColor: AppTheme.primaryGreen.withOpacity(0.3),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.glassDecoration.copyWith(
        color: Colors.white.withOpacity(0.05),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: Icon(icon, color: AppTheme.primaryBlue),
        trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
        onTap: onTap,
      ),
    );
  }
}
