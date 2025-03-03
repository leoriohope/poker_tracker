import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Locale) onLocaleChanged;
  
  const SettingsScreen({
    super.key,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            trailing: const Icon(Icons.language),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(l10n.language),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        onLocaleChanged(const Locale('en'));
                        Navigator.pop(context);
                      },
                      child: const Text('English'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        onLocaleChanged(const Locale('zh'));
                        Navigator.pop(context);
                      },
                      child: const Text('中文'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        onLocaleChanged(const Locale('es'));
                        Navigator.pop(context);
                      },
                      child: const Text('Español'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 