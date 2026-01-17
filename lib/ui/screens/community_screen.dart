import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/event_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/event_models.dart';
import '../../data/models/user_models.dart';
import 'package:intl/intl.dart';
import '../../data/services/geocoding_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Event> _events = [];
  bool _isLoading = true;
  UserPublic? _currentUser;

  // Filter State
  List<Map<String, dynamic>> _italianCities = [];
  Map<String, dynamic>? _selectedCityData; // {name, province}
  double _searchRadius = 10.0;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    await _loadCities();
    // Load currentUser and default location
    if (!mounted) return;
    try {
      _currentUser = await authService.getCurrentUser();

      // Attempt to pre-fill city based on User/Org
      await _setDefaultCity(authService);
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
    // Finally load events
    _loadEvents();
  }

  Future<void> _loadCities() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/italian_cities.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _italianCities = List<Map<String, dynamic>>.from(jsonList);
      });
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  Future<void> _setDefaultCity(AuthService authService) async {
    if (_currentUser == null) return;

    String? cityToFind;

    if (_currentUser!.userType == UserType.organization) {
      cityToFind = _currentUser!.residentialData?.city;
    } else if (_currentUser!.userType == UserType.member &&
        _currentUser!.organizationId != null) {
      try {
        final org = await authService.getUser(_currentUser!.organizationId!);
        // Using currentUser structure assuming get User returns UserPublic-like data logic
        // The implementation in AuthService returns UserPublic which extends UserReference but actually has data
        // We need to cast or access properly. AuthService.getUser returns UserReference? but implementation returns UserPublic?
        // Checking AuthService source code from context...
        // Logic: The AuthService.getUser returns UserReference in signature but implementation returns UserPublic.
        // I will assume for now I can cast or better, safe check.

        // Actually AuthService.getUser signature is Future<UserReference?> but body returns UserPublic.fromJson.
        // UserReference doesn't have residentialData. UserPublic does.
        // I'll trust standard implementation or just use generic check.
        if (org is UserPublic) {
          cityToFind = org.residentialData?.city;
        }
      } catch (e) {
        debugPrint('Error fetching organization for default city: $e');
      }
    }

    if (cityToFind != null && _italianCities.isNotEmpty) {
      // Find case-insensitive match
      final match = _italianCities.firstWhere(
        (element) =>
            element['name'].toString().toLowerCase() ==
            cityToFind!.toLowerCase(),
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        setState(() {
          _selectedCityData = match;
          _cityController.text = '${match['name']} (${match['province']})';
        });
      }
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final eventService = context.read<EventService>();
      final geocodingService = context.read<GeocodingService>();

      List<Event> events = [];

      int? prioritizedOrgId;
      if (_currentUser?.userType == UserType.member) {
        prioritizedOrgId = _currentUser?.organizationId;
      } else if (_currentUser?.userType == UserType.organization) {
        prioritizedOrgId = _currentUser?.userId;
      }

      // If we have a city selected, geocode and search
      if (_selectedCityData != null) {
        final cityName = _selectedCityData!['name'];
        final province = _selectedCityData!['province'];
        debugPrint(
          'Selected city: $cityName ($province), calling geocoding service...',
        );
        final coords = await geocodingService.geocodeAddress(
          city: cityName,
          province: province,
        );
        debugPrint('Geocoding result: $coords');

        if (coords != null) {
          debugPrint('Calling getEventsInRadius with coords: $coords');
          events = await geocodingService.getEventsInRadius(
            latitude: coords['latitude']!,
            longitude: coords['longitude']!,
            radius: _searchRadius * 1000,
          );
          debugPrint('Events in radius: ${events.length}');
          // Custom sort using valid prioritizedOrgId
          if (prioritizedOrgId != null) {
            events.sort((a, b) {
              final aIsOrg = a.author.userId == prioritizedOrgId;
              final bIsOrg = b.author.userId == prioritizedOrgId;
              if (aIsOrg && !bIsOrg) return -1;
              if (!aIsOrg && bIsOrg) return 1;
              return b.dateTime.compareTo(a.dateTime);
            });
          } else {
            events.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          }
        } else {
          // Geocode failed
          events = [];
        }
      } else {
        // No filter, show all
        events = await eventService.getEvents(
          userOrganizationId: prioritizedOrgId,
        );
        debugPrint('Events without filter: ${events.length}');
      }

      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading community data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrganization = _currentUser?.userType == UserType.organization;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.communityEventsTitle),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          ExpansionTile(
            title: Text(
              AppLocalizations.of(context)!.communityScreenFiltersTitle,
            ),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 24.0,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Autocomplete<Map<String, dynamic>>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '') {
                                    return const Iterable<
                                      Map<String, dynamic>
                                    >.empty();
                                  }
                                  return _italianCities.where((
                                    Map<String, dynamic> option,
                                  ) {
                                    return option['name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(
                                          textEditingValue.text.toLowerCase(),
                                        );
                                  });
                                },
                            displayStringForOption:
                                (Map<String, dynamic> option) =>
                                    '${option['name']} (${option['province']})',
                            onSelected: (Map<String, dynamic> selection) {
                              setState(() {
                                _selectedCityData = selection;
                              });
                            },
                            fieldViewBuilder:
                                (
                                  BuildContext context,
                                  TextEditingController
                                  fieldTextEditingController,
                                  FocusNode fieldFocusNode,
                                  VoidCallback onFieldSubmitted,
                                ) {
                                  if (_cityController.text.isNotEmpty &&
                                      fieldTextEditingController.text.isEmpty) {
                                    fieldTextEditingController.text =
                                        _cityController.text;
                                  }
                                  return TextField(
                                    controller: fieldTextEditingController,
                                    focusNode: fieldFocusNode,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.communityScreenCityLabel,
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_city),
                                    ),
                                  );
                                },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<double>(
                            initialValue: _searchRadius,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(
                                context,
                              )!.communityScreenDistanceLabel,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 15,
                              ),
                            ),
                            items: [10.0, 50.0, 100.0, 150.0, 200.0].map((
                              double value,
                            ) {
                              return DropdownMenuItem<double>(
                                value: value,
                                child: Text('${value.round()} km'),
                              );
                            }).toList(),
                            onChanged: (double? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _searchRadius = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadEvents,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.communityScreenApplyFilterButton,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                ? Center(
                    child: Text(AppLocalizations.of(context)!.noEventsFound),
                  )
                : ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      final isMyOrg =
                          event.author.userId == _currentUser?.userId ||
                          (isOrganization &&
                              event.author.userId == _currentUser?.userId);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        // Highlight events from own organization
                        color: isMyOrg
                            ? Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1)
                            : null,
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.event, color: Colors.white),
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                event.author.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${DateFormat('MMM d, y • h:mm a').format(DateTime.parse(event.dateTime))} • ${event.locationData.formatted_address()}',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            context.push('/event-details', extra: event);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
