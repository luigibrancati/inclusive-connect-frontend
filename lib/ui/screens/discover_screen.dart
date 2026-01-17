import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_models.dart';

import '../../data/services/user_service.dart';
import '../widgets/cached_storage_image.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserPublic> _members = [];
  List<UserPublic> _organizations = [];
  bool _isLoading = false;
  Timer? _debounce;

  // City Filter
  List<Map<String, dynamic>> _italianCities = [];
  Map<String, dynamic>? _selectedCityData;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCities();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
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

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    final city = _selectedCityData?['name'] as String?;

    // If both empty, load default data
    if (query.isEmpty && city == null) {
      _fetchData();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = context.read<UserService>();
      // Pass city to searchUsers
      final users = await userService.searchUsers(query);

      final members = users
          .where((user) => user.userType == UserType.member)
          .toList();
      final organizations = users
          .where((user) => user.userType == UserType.organization)
          .toList();

      if (mounted) {
        setState(() {
          _members = members;
          _organizations = organizations;
        });
      }
    } catch (e) {
      // Handle error gently
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userService = context.read<UserService>();
      // Fetch both for discover
      final users = await userService.getAllUsers();
      final members = users
          .where((user) => user.userType == UserType.member)
          .toList();
      final organizations = users
          .where((user) => user.userType == UserType.organization)
          .toList();

      if (mounted) {
        setState(() {
          _members = members;
          _organizations = organizations;
        });
      }
    } catch (e) {
      // Handle error gently
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.discoverScreenTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(
                  context,
                )!.searchPeopleOrganizations,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: Text(
              AppLocalizations.of(context)!.communityScreenFiltersTitle,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    return _italianCities.where((Map<String, dynamic> option) {
                      return option['name'].toString().toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      '${option['name']} (${option['province']})',
                  onSelected: (Map<String, dynamic> selection) {
                    setState(() {
                      _selectedCityData = selection;
                      _cityController.text =
                          selection['name']; // Keep text in sync if needed or just use selection
                    });
                    _performSearch(_searchController.text);
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        // Sync with our controller if we want to programmatically set it,
                        // though Autocomplete manages its own controller usually.
                        // We can just use the one provided.
                        return TextField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.communityScreenCityLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.location_city),
                            suffixIcon: _selectedCityData != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _selectedCityData = null;
                                        fieldTextEditingController.clear();
                                      });
                                      _performSearch(_searchController.text);
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.discoverOrganizationsSectionTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_organizations.isEmpty)
                        Text(
                          AppLocalizations.of(context)!.noOrganizationsFound,
                        ),
                      ..._organizations.map(
                        (org) => InkWell(
                          onTap: () {
                            context.push('/users/${org.userId}');
                          },
                          child: ListTile(
                            leading: org.profilePicUrl != null
                                ? SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CachedStorageImage(
                                      org.profilePicUrl,
                                      width: 40,
                                      height: 40,
                                      circle: true,
                                    ),
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.business),
                                  ),
                            title: Text(org.username),
                            subtitle: Text(org.residentialData!.city),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        AppLocalizations.of(
                          context,
                        )!.discoverMembersSectionTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_members.isEmpty)
                        Text(AppLocalizations.of(context)!.noMembersFound),
                      ..._members.map(
                        (member) => InkWell(
                          onTap: () {
                            context.push('/users/${member.userId}');
                          },
                          child: ListTile(
                            leading: member.profilePicUrl != null
                                ? SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CachedStorageImage(
                                      member.profilePicUrl,
                                      width: 40,
                                      height: 40,
                                      circle: true,
                                    ),
                                  )
                                : const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(member.username),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
