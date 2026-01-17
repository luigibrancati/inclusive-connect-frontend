import 'package:flutter/material.dart';
import 'package:inclusive_connect/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_models.dart';
import '../widgets/accessibility_controls.dart';

class RegisterMemberScreen extends StatefulWidget {
  const RegisterMemberScreen({super.key});

  @override
  State<RegisterMemberScreen> createState() => _RegisterMemberScreenState();
}

class _RegisterMemberScreenState extends State<RegisterMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _organizationIdController = TextEditingController();
  bool _inviteCodeIsValid = false;
  bool _isCheckingInviteCode = false;

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
        final memberCreate = UserCreate(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          userType: UserType.member,
          bio: _bioController.text.isNotEmpty ? _bioController.text : null,
          inviteCode: _inviteCodeController.text,
          organizationId: int.parse(_organizationIdController.text),
        );

        await context.read<AuthService>().registerMember(memberCreate);

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

  Future<void> validateInviteCode(String? code) async {
    debugPrint('Validating invite code: $code');
    if (code == null || code.isEmpty) {
      debugPrint('Invite code is empty');
      _inviteCodeIsValid = false;
    }
    try {
      final value = await context.read<AuthService>().getInviteCodeOrgId(code!);
      debugPrint('Fetched organization ID: $value for invite code: $code');
      setState(() {
        _organizationIdController.text = value.toString();
        _inviteCodeIsValid = true;
        _isCheckingInviteCode = false;
      });
    } catch (e) {
      debugPrint('Error validating invite code: $e');
      setState(() {
        _organizationIdController.text = '';
        _inviteCodeIsValid = false;
        _isCheckingInviteCode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.joinWithInviteCode),
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
            if (_inviteCodeIsValid == false && _currentStep == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.pleaseEnterAValidInviteCode,
                  ),
                ),
              );
              return;
            }
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
              title: Text(AppLocalizations.of(context)!.inviteCodeInputTitle),
              content: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _inviteCodeController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.inviteCodeInputLabel,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppLocalizations.of(
                              context,
                            )!.inviteCodeRequiredError
                          : (_inviteCodeIsValid
                                ? null
                                : AppLocalizations.of(
                                    context,
                                  )!.inviteCodeInvalidError),
                      onChanged: (value) {
                        setState(() {
                          _inviteCodeIsValid = false;
                          _isCheckingInviteCode = false;
                        });
                      },
                    ),
                    const SizedBox(width: 18),
                    _inviteCodeIsValid
                        ? Text(
                            AppLocalizations.of(context)!.inviteCodeValid,
                            style: const TextStyle(color: Colors.green),
                          )
                        : _isCheckingInviteCode
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : TextButton(
                            onPressed: () async {
                              setState(() {
                                _isCheckingInviteCode = true;
                              });
                              await validateInviteCode(
                                _inviteCodeController.text,
                              );
                              setState(() {
                                _isCheckingInviteCode = false;
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context)!.checkCodeButton,
                            ),
                          ),
                  ],
                ),
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: Text(AppLocalizations.of(context)!.accountDetailsTitle),
              content: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.usernameLabel,
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
              isActive: _currentStep >= 1,
            ),
          ],
        ),
      ),
    );
  }
}
