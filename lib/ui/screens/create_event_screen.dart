import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inclusive_connect/data/models/common_models.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/services/event_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_models.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetController = TextEditingController();
  final _streetNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _countryController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isCreating = false;

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
    _streetNumberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _createEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _streetNumberController.text.isEmpty ||
        _postalCodeController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _provinceController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.createEventFillAllFieldsError,
          ),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final authService = context.read<AuthService>();
      final eventService = context.read<EventService>();
      final user = await authService.getCurrentUser();

      if (user == null || user.userType != UserType.organization) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.createEventOrganizationError,
              ),
            ),
          );
        }
        return;
      }

      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await eventService.createEvent(
        _titleController.text,
        _descriptionController.text,
        LocationData(
          street: _streetController.text,
          streetNumber: int.tryParse(_streetNumberController.text)!,
          postalCode: int.tryParse(_postalCodeController.text)!,
          city: _cityController.text,
          province: _provinceController.text,
          country: _countryController.text,
        ),
        eventDateTime,
        images: _selectedImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.createEventSuccess),
          ),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('Error creating event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.createEventFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createEventTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          _isCreating
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _createEvent,
                  child: Text(
                    AppLocalizations.of(context)!.createEventCreateButton,
                  ),
                ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  )!.createEventTitleInputLabel,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate == null
                      ? AppLocalizations.of(context)!.createEventDateInputLabel
                      : DateFormat('MMM d, y').format(_selectedDate!),
                ),
                onTap: _pickDate,
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  _selectedTime == null
                      ? AppLocalizations.of(context)!.createEventTimeInputLabel
                      : _selectedTime!.format(context),
                ),
                onTap: _pickTime,
              ),
              // ListTile(
              //   leading: const Icon(Icons.location_on),
              //   title: TextField(
              //     controller: _locationController,
              //     decoration: InputDecoration(
              //       hintText: AppLocalizations.of(
              //         context,
              //       )!.createEventLocationInputLabel,
              //       border: InputBorder.none,
              //     ),
              //   ),
              // ),
              Column(
                children: [
                  TextFormField(
                    controller: _streetController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.streetLabel,
                    ),
                  ),
                  TextFormField(
                    controller: _streetNumberController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.streetNumberLabel,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.cityLabel,
                    ),
                  ),
                  TextFormField(
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.postalCodeLabel,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _provinceController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.provinceLabel,
                    ),
                  ),
                  TextFormField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.countryLabel,
                    ),
                  ),
                ],
              ),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: InkWell(
                              onTap: () => _removeImage(index),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                  ),
                  IconButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    )!.createEventDescriptionInputLabel,
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
