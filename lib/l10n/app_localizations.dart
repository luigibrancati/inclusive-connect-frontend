import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Inclusive Connect'**
  String get appTitle;

  /// Title for the Create Event screen
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEventTitle;

  /// The subtitle of the application in the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Your Safe Space to Connect'**
  String get appSubtitle;

  /// The presentation of the application in the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Join a supportive community designed for individuals with autism and the organizations that champion them. Be yourself, together.'**
  String get appPresentation;

  /// The join as option in the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Join as...'**
  String get joinAs;

  /// The create account option in the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// The login option in the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// The already a member option in the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Already a member? Log in'**
  String get alreadyAMember;

  /// The member option name
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// The organization option name
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// The welcome back message in the login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// The please enter your details to sign in message in the login screen
  ///
  /// In en, this message translates to:
  /// **'Please enter your details to sign in.'**
  String get pleaseEnterYourDetailsToSignIn;

  /// The email label in the login screen
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// The email hint in the login screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailHint;

  /// The email empty error in the login screen
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get loginEmailEmptyError;

  /// The password label in the login screen
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// The password hint in the login screen
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// The password empty error in the login screen
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get loginPasswordEmptyError;

  /// The login button in the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// The forgot password option in the login screen
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// The login failed message in the login screen
  ///
  /// In en, this message translates to:
  /// **'Login failed: invalid credentials'**
  String get loginFailed;

  /// The passwords do not match message in the register screen
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// The registration successful message in the register screen
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please login.'**
  String get registrationSuccessful;

  /// The registration failed message in the register screen
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// The join with invite code message in the register screen
  ///
  /// In en, this message translates to:
  /// **'Join with Invite Code'**
  String get joinWithInviteCode;

  /// The please enter a valid invite code message in the register screen
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid invite code'**
  String get pleaseEnterAValidInviteCode;

  /// The back button in the register screen
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// The continue button in the register screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// The register button in the register screen
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// The invite code input title in the register screen
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCodeInputTitle;

  /// The invite code input label in the register screen
  ///
  /// In en, this message translates to:
  /// **'Enter Invite Code'**
  String get inviteCodeInputLabel;

  /// The invite code required error in the register screen
  ///
  /// In en, this message translates to:
  /// **'Invite code is required'**
  String get inviteCodeRequiredError;

  /// The invite code invalid error in the register screen
  ///
  /// In en, this message translates to:
  /// **'Invalid invite code'**
  String get inviteCodeInvalidError;

  /// The check code button in the register screen
  ///
  /// In en, this message translates to:
  /// **'Check Code'**
  String get checkCodeButton;

  /// The invite code valid message in the register screen
  ///
  /// In en, this message translates to:
  /// **'Invite code is valid'**
  String get inviteCodeValid;

  /// The account details title in the register screen
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetailsTitle;

  /// The username label in the register screen
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// The email label in the register screen
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// The password label in the register screen
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// The confirm password label in the register screen
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// The bio label in the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// The bio hint in the register screen
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get bioHint;

  /// The register organization screen title
  ///
  /// In en, this message translates to:
  /// **'Register Organization'**
  String get registerOrganizationScreenTitle;

  /// The account details step title in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetailsStepTitle;

  /// The organization name label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get organizationNameLabel;

  /// The address step title in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressStepTitle;

  /// The street label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get streetLabel;

  /// The street number label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Street Number'**
  String get streetNumberLabel;

  /// The city label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// The postal code label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCodeLabel;

  /// The province label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get provinceLabel;

  /// The country label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// The fiscal data step title in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Fiscal Data'**
  String get fiscalDataStepTitle;

  /// The fiscal code label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'Fiscal Code'**
  String get fiscalCodeLabel;

  /// The VAT number label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get vatNumberLabel;

  /// The ATECO code label in the register organization screen
  ///
  /// In en, this message translates to:
  /// **'ATECO Code (Optional)'**
  String get atecoCodeLabel;

  /// The accessibility settings in the settings screen
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettings;

  /// The manage invite codes settings in the settings screen
  ///
  /// In en, this message translates to:
  /// **'Manage Invite Codes'**
  String get manageInviteCodesSettings;

  /// The edit profile in the settings screen
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// The share profile in the settings screen
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// The logout in the settings screen
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// The member of organization in the profile screen
  ///
  /// In en, this message translates to:
  /// **'Member of Organization'**
  String get memberOfOrganization;

  /// The bio label in the profile screen
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBioLabel;

  /// The posts stats in the profile screen
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsStats;

  /// The followers stats in the profile screen
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followersStats;

  /// The following stats in the profile screen
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingStats;

  /// The posts profile section title in the profile screen
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsProfileSectionTitle;

  /// The failed to update like message in the post card
  ///
  /// In en, this message translates to:
  /// **'Failed to update like'**
  String get failedToUpdateLike;

  /// The simplification failed message in the post card
  ///
  /// In en, this message translates to:
  /// **'Failed to simplify text'**
  String get simplificationFailed;

  /// The just now message in the post card
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// The TTS posted message in the post card
  ///
  /// In en, this message translates to:
  /// **'posted'**
  String get posted;

  /// The simplified text label in the post card
  ///
  /// In en, this message translates to:
  /// **'Simplified'**
  String get simplifiedTextLabel;

  /// The simplify content button tooltip in the post card
  ///
  /// In en, this message translates to:
  /// **'Simplify content'**
  String get simplifyContentButtonTooltip;

  /// The post details screen title
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postDetailsScreenTitle;

  /// The create post button title in the main shell
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPostButtonTitle;

  /// The create event button title in the main shell
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEventButtonTitle;

  /// The community feed title in the home screen
  ///
  /// In en, this message translates to:
  /// **'Community Feed'**
  String get communityFeedTitle;

  /// The all posts chip title in the home screen
  ///
  /// In en, this message translates to:
  /// **'All Posts'**
  String get allPostsChipTitle;

  /// The trending chip title in the home screen
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trendingChipTitle;

  /// The sensory friendly chip title in the home screen
  ///
  /// In en, this message translates to:
  /// **'Sensory Friendly'**
  String get sensoryFriendlyChipTitle;

  /// The meetups chip title in the home screen
  ///
  /// In en, this message translates to:
  /// **'Meetups'**
  String get meetupsChipTitle;

  /// The Q&A chip title in the home screen
  ///
  /// In en, this message translates to:
  /// **'Q&A'**
  String get qaChipTitle;

  /// The error loading feed message in the home screen
  ///
  /// In en, this message translates to:
  /// **'Error loading feed'**
  String get errorLoadingFeed;

  /// The no posts found message in the home screen
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get noPostsFound;

  /// The retry button in the home screen
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// The event details title in the event details screen
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetailsTitle;

  /// The organized by label in the event details screen
  ///
  /// In en, this message translates to:
  /// **'Organized by'**
  String get organizedBy;

  /// The about this event label in the event details screen
  ///
  /// In en, this message translates to:
  /// **'About this event'**
  String get aboutThisEvent;

  /// The create event fill all fields error in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get createEventFillAllFieldsError;

  /// The create event organization error in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Only organizations can create events'**
  String get createEventOrganizationError;

  /// The create event success message in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Event created successfully!'**
  String get createEventSuccess;

  /// The create event failed message in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Failed to create event'**
  String get createEventFailed;

  /// The create event create button in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createEventCreateButton;

  /// The create event title input label in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get createEventTitleInputLabel;

  /// The create event date input label in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get createEventDateInputLabel;

  /// The create event time input label in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get createEventTimeInputLabel;

  /// The create event location input label in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get createEventLocationInputLabel;

  /// The create event description input label in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createEventDescriptionInputLabel;

  /// The create event description input placeholder in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createEventDescriptionInputPlaceholder;

  /// The create event description input hint in the create event screen
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createEventDescriptionInputHint;

  /// The display name label in the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayNameLabel;

  /// The display name required error in the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Please enter a display name'**
  String get displayNameRequiredError;

  /// The profile updated successfully message in the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// The profile update failed message in the edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// The discover screen title
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverScreenTitle;

  /// The search people organizations hint in the discover screen
  ///
  /// In en, this message translates to:
  /// **'Search people, organizations...'**
  String get searchPeopleOrganizations;

  /// The discover organizations section title in the discover screen
  ///
  /// In en, this message translates to:
  /// **'Organizations'**
  String get discoverOrganizationsSectionTitle;

  /// The no organizations found message in the discover screen
  ///
  /// In en, this message translates to:
  /// **'No organizations found.'**
  String get noOrganizationsFound;

  /// The follow feature coming soon message in the discover screen
  ///
  /// In en, this message translates to:
  /// **'Follow feature coming soon!'**
  String get followFeatureComingSoon;

  /// The follow button in the discover screen
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// The discover members section title in the discover screen
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get discoverMembersSectionTitle;

  /// The no members found message in the discover screen
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get noMembersFound;

  /// The connect feature coming soon message in the discover screen
  ///
  /// In en, this message translates to:
  /// **'Connect feature coming soon!'**
  String get connectFeatureComingSoon;

  /// The connect button in the discover screen
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// The analyze tone write at least one word message in the create post screen
  ///
  /// In en, this message translates to:
  /// **'Write at least a few words...'**
  String get analyzeToneWriteAtLeastOneWord;

  /// The analyze tone button in the create post screen
  ///
  /// In en, this message translates to:
  /// **'Analizza Tono'**
  String get analyzeToneButton;

  /// The new post title in the create post screen
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get newPostTitle;

  /// The submit post fill all fields message in the create post screen
  ///
  /// In en, this message translates to:
  /// **'Fill all fields'**
  String get submitPostFillAllFields;

  /// The post created successfully message in the create post screen
  ///
  /// In en, this message translates to:
  /// **'Post created successfully!'**
  String get postCreatedSuccessfully;

  /// The post creation failed message in the create post screen
  ///
  /// In en, this message translates to:
  /// **'Failed to create post'**
  String get postCreationFailed;

  /// The new post title hint in the create post screen
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get newPostTitleHint;

  /// The new post body hint in the create post screen
  ///
  /// In en, this message translates to:
  /// **'What do you want to share?'**
  String get newPostBodyHint;

  /// The new post action button post in the create post screen
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get newPostActionButtonPost;

  /// The alt text in the create post screen
  ///
  /// In en, this message translates to:
  /// **'ALT'**
  String get altText;

  /// The community events title in the community screen
  ///
  /// In en, this message translates to:
  /// **'Community Events'**
  String get communityEventsTitle;

  /// The no events found message in the community screen
  ///
  /// In en, this message translates to:
  /// **'No events found.'**
  String get noEventsFound;

  /// The accessibility settings title in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettingsTitle;

  /// The visibility settings title in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Visibility Settings'**
  String get visibilitySettingsTitle;

  /// The high contrast setting title in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrastSettingTitle;

  /// The high contrast setting subtitle in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Use high contrast colors (Yellow on Black)'**
  String get highContrastSettingSubtitle;

  /// The typography settings title in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Typography Settings'**
  String get typographySettingsTitle;

  /// The typography settings label title in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Dyslexia-Friendly Font'**
  String get typographySettingsLabelTitle;

  /// The typography settings label subtitle in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Use dyslexia-friendly font'**
  String get typographySettingsLabelSubtitle;

  /// The TTS settings title in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Text-to-Speech Settings'**
  String get ttsSettingsTitle;

  /// The TTS settings Italian language not detected message in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Italian language not detected!'**
  String get ttsSettingsItalianLanguageNotDetected;

  /// The TTS settings install Italian language message in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'For a better experience, install italian language'**
  String get ttsSettingsInstallItalianLanguage;

  /// The TTS settings install Italian language button label in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Install Now'**
  String get ttsSettingsInstallItalianLanguageButtonLabel;

  /// The TTS settings test button label in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Listen Settings'**
  String get ttsSettingsTestButtonLabel;

  /// The test components title in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Test Components'**
  String get testComponentsTitle;

  /// The test components button label in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Test Button'**
  String get testComponentsButtonLabel;

  /// The TTS settings speech rate label in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Speech Rate'**
  String get ttsSettingsSpeechRateLabel;

  /// The typography settings text size label in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get typographySettingsTextSizeLabel;

  /// The TTS settings pitch label in the accessibility settings screen
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get ttsSettingsPitchLabel;

  /// The invite code generated successfully message in the invite codes screen
  ///
  /// In en, this message translates to:
  /// **'Invite code generated successfully!'**
  String get inviteCodeGeneratedSuccessfully;

  /// The invite code generation failed message in the invite codes screen
  ///
  /// In en, this message translates to:
  /// **'Failed to generate invite code'**
  String get inviteCodeGenerationFailed;

  /// The invite code revoked successfully message in the invite codes screen
  ///
  /// In en, this message translates to:
  /// **'Invite code revoked successfully!'**
  String get inviteCodeRevokedSuccessfully;

  /// The invite code revocation failed message in the invite codes screen
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke invite code'**
  String get inviteCodeRevocationFailed;

  /// The invite codes screen title
  ///
  /// In en, this message translates to:
  /// **'Invite Codes'**
  String get inviteCodesScreenTitle;

  /// The invite codes screen refreshed message
  ///
  /// In en, this message translates to:
  /// **'List updated'**
  String get inviteCodesScreenRefreshed;

  /// The invite codes screen refresh tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get inviteCodesScreenRefreshTooltip;

  /// The invite codes screen generate tooltip
  ///
  /// In en, this message translates to:
  /// **'Generate new code'**
  String get inviteCodesScreenGenerateTooltip;

  /// The invite codes screen error message
  ///
  /// In en, this message translates to:
  /// **'Error when loading invite codes'**
  String get inviteCodesScreenError;

  /// The invite codes screen no codes generated message
  ///
  /// In en, this message translates to:
  /// **'No invite codes generated'**
  String get inviteCodesScreenNoCodesGenerated;

  /// The invite codes screen copied to clipboard message
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get inviteCodesScreenCopiedToClipboard;

  /// The invite codes screen created at message
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get inviteCodesScreenCreatedAt;

  /// The invite codes screen max uses message
  ///
  /// In en, this message translates to:
  /// **'Max uses'**
  String get inviteCodesScreenMaxUses;

  /// The invite codes screen current uses message
  ///
  /// In en, this message translates to:
  /// **'Current uses'**
  String get inviteCodesScreenCurrentUses;

  /// The invite codes screen invalid message
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get inviteCodesScreenInvalid;

  /// The invite codes screen uses message
  ///
  /// In en, this message translates to:
  /// **'Uses'**
  String get inviteCodesScreenUses;

  /// The invite codes screen expired message
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get inviteCodesScreenExpired;

  /// The invite codes screen fully used message
  ///
  /// In en, this message translates to:
  /// **'Fully used'**
  String get inviteCodesScreenFullyUsed;

  /// The invite codes screen revoke tooltip
  ///
  /// In en, this message translates to:
  /// **'Revoke code'**
  String get inviteCodesScreenRevokeTooltip;

  /// The invite codes screen revoke title
  ///
  /// In en, this message translates to:
  /// **'Revoke code'**
  String get inviteCodesScreenRevokeTitle;

  /// The invite codes screen revoke code cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inviteCodesScreenRevokeCodeCancel;

  /// The invite codes screen revoke code confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get inviteCodesScreenRevokeCodeConfirm;

  /// The invite codes screen revoke code confirm text
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke the code? This action cannot be undone.'**
  String get inviteCodesScreenRevokeCodeConfirmText;

  /// The community screen filters title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get communityScreenFiltersTitle;

  /// The community screen city label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get communityScreenCityLabel;

  /// The community screen distance label
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get communityScreenDistanceLabel;

  /// The community screen apply filter button
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get communityScreenApplyFilterButton;

  /// Buttton to follow a user
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followButton;

  /// Button to unfollow a user
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollowButton;

  /// Button to request friendship
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriendButton;

  /// Button indicating friendship status
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friendButton;

  /// Button indicating a sent friend request
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requestedButton;

  /// Button to accept a friend request
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequestButton;

  /// Snack bar that shows up when posting the comment has failed
  ///
  /// In en, this message translates to:
  /// **'Failed to post comment'**
  String get failedToPostCommentSnackBarText;

  /// Title of the comments section
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsSectionTitle;

  /// Text shown when loading smart replies
  ///
  /// In en, this message translates to:
  /// **'Smart replies loading...'**
  String get smartRepliesLoadingText;

  /// Hint text for the comment input
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addCommentHintText;

  /// Text shown when there are no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get noCommentsText;

  /// Text shown when alt text generation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to generate alt text'**
  String get failedToGenerateAltText;

  /// Text shown when loading alt text
  ///
  /// In en, this message translates to:
  /// **'Generating alt text for the image...'**
  String get loadingAltTextLoadingText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
