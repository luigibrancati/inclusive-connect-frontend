import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:inclusive_connect/data/services/theme_service.dart';
import 'package:inclusive_connect/data/services/tts_service.dart';
import 'package:inclusive_connect/ui/widgets/insta_button.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.accessibilitySettingsTitle),
      ),
      body: Consumer2<ThemeService, TtsService>(
        builder: (context, themeService, ttsService, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.visibilitySettingsTitle,
              ),
              SwitchListTile(
                title: Text(
                  AppLocalizations.of(context)!.highContrastSettingTitle,
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.highContrastSettingSubtitle,
                ),
                value: themeService.highContrast,
                onChanged: (value) => themeService.setHighContrast(value),
              ),
              const Divider(),
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.typographySettingsTitle,
              ),
              SwitchListTile(
                title: Text(
                  AppLocalizations.of(context)!.typographySettingsLabelTitle,
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.typographySettingsLabelSubtitle,
                ),
                value: themeService.readableFont,
                onChanged: (value) => themeService.setReadableFont(value),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${AppLocalizations.of(context)!.typographySettingsTextSizeLabel}: ${(themeService.textScaleFactor * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Slider(
                value: themeService.textScaleFactor,
                min: 1.0,
                max: 1.5,
                divisions: 5,
                label: '${(themeService.textScaleFactor * 100).toInt()}%',
                onChanged: (value) => themeService.setTextScale(value),
              ),
              const Divider(),
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.ttsSettingsTitle,
              ),
              if (!ttsService.isItalianAvailable)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange[900],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.ttsSettingsItalianLanguageNotDetected,
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.ttsSettingsInstallItalianLanguage,
                          style: TextStyle(color: Colors.orange[900]),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                ttsService.installItalianLanguage(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange[900],
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.ttsSettingsInstallItalianLanguageButtonLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${AppLocalizations.of(context)!.ttsSettingsSpeechRateLabel}: ${(ttsService.speechRate * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Slider(
                value: ttsService.speechRate,
                min: 0.1,
                max: 1.3,
                divisions: 24,
                label: '${(ttsService.speechRate * 100).toInt()}%',
                onChanged: (value) => ttsService.setSpeechRate(value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${AppLocalizations.of(context)!.ttsSettingsPitchLabel}: ${(ttsService.pitch * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Slider(
                value: ttsService.pitch,
                min: 0.1,
                max: 1.5,
                divisions: 28,
                label: '${(ttsService.pitch * 100).toInt()}%',
                onChanged: (value) => ttsService.setPitch(value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Center(
                  child: InstaButton(
                    onPressed: () {
                      ttsService.test();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.ttsSettingsTestButtonLabel,
                    ),
                  ),
                ),
              ),
              const Divider(),
              _buildSectionHeader(
                context,
                AppLocalizations.of(context)!.testComponentsTitle,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InstaButton(
                  onPressed: () {},
                  child: Text(
                    AppLocalizations.of(context)!.testComponentsButtonLabel,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
