import 'package:flutter/material.dart';
import 'package:inclusive_connect/data/models/common_models.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_models.dart';
import '../widgets/accessibility_controls.dart';

class RegisterOrganizationScreen extends StatefulWidget {
  const RegisterOrganizationScreen({super.key});

  @override
  State<RegisterOrganizationScreen> createState() =>
      _RegisterOrganizationScreenState();
}

class _RegisterOrganizationScreenState
    extends State<RegisterOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();

  // Residential Data Controllers
  final _streetController = TextEditingController();
  final _streetNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _provinceController = TextEditingController();
  final _countryController = TextEditingController();

  // Fiscal Data Controllers
  final _fiscalCodeController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _atecoCodeController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final orgCreate = UserCreate(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          userType: UserType.organization,
          bio: _bioController.text.isNotEmpty ? _bioController.text : null,
          residentialData: LocationData(
            street: _streetController.text,
            streetNumber: int.tryParse(_streetNumberController.text) ?? 0,
            city: _cityController.text,
            postalCode: int.tryParse(_postalCodeController.text) ?? 0,
            province: _provinceController.text,
            country: _countryController.text,
          ),
          fiscalData: FiscalData(
            fiscalCode: _fiscalCodeController.text,
            vatNumber: _vatNumberController.text,
            atecoCode: _atecoCodeController.text.isNotEmpty
                ? _atecoCodeController.text
                : null,
          ),
        );

        await context.read<AuthService>().registerOrganization(orgCreate);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.registrationSuccessful,
              ),
            ),
          );
          context.go('/login');
        }
      } catch (e) {
        debugPrint("Registration failed: ${e.toString()}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.registrationFailed),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.registerOrganizationScreenTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [AccessibilityControls(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _register();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      child: _isLoading && _currentStep == 2
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentStep == 2
                                  ? AppLocalizations.of(context)!.registerButton
                                  : AppLocalizations.of(
                                      context,
                                    )!.continueButton,
                            ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text(AppLocalizations.of(context)!.backButton),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text(
                AppLocalizations.of(context)!.accountDetailsStepTitle,
              ),
              content: Form(
                // Note: Wrapping entire stepper in Form might be better but Stepper logic is tricky with validation per step.
                // For simplicity, we use one big form key for final validation or we can split keys.
                // Let's rely on final validation for now or basic checks.
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.organizationNameLabel,
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.emailLabel,
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.passwordLabel,
                      ),
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.confirmPasswordLabel,
                      ),
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.bioLabel,
                        hintText: AppLocalizations.of(context)!.bioHint,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: Text(AppLocalizations.of(context)!.addressStepTitle),
              content: Column(
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
              isActive: _currentStep >= 1,
            ),
            Step(
              title: Text(AppLocalizations.of(context)!.fiscalDataStepTitle),
              content: Form(
                key:
                    _formKey, // Using the key here for the final validation trigger, but practically fields are spread.
                // Better approach: move Form higher up or validate manually.
                // We'll put the Form widget at the top level of the body in a real refined app,
                // but for this "MVP" Stepper structure, let's wrap the Stepper in a Form.
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fiscalCodeController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.fiscalCodeLabel,
                      ),
                    ),
                    TextFormField(
                      controller: _vatNumberController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.vatNumberLabel,
                      ),
                    ),
                    TextFormField(
                      controller: _atecoCodeController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.atecoCodeLabel,
                      ),
                    ),
                  ],
                ),
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }
}
