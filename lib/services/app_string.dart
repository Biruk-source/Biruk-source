import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Needed for DateFormat potentially
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart'; // You WILL need to create this provider file

// --- Abstract Class for All Strings ---
// Defines the contract for all localizations
abstract class AppStrings {
  Locale get locale;

  // --- General ---
  String get appTitle;
  String get highContrastTooltip;
  String get specifyInDescription;
  String get darkModeTooltip;
  String get languageToggleTooltip;
  Map<String, List<String>> get jobCategoriesAndSkills;
  String get errorInitializationFailed;
  String get errorCouldNotSavePrefs;
  String get errorConnectivityCheck;
  String get errorActionFailed;
  String get errorCouldNotLaunchUrl;
  String get errorCouldNotLaunchDialer;
  String get successPrefsSaved;
  String get successSubscription;
  String get connectionRestored;
  String get noInternet;
  String get retryButton;
  String get errorGeneric;
  String get loading;
  String get generalCancel;
  String get generalLogout;
  String get clear;
  String get ok;
  String get notAvailable;
  String get notSet;

  // --- HomeScreen ---
  String helloUser(String userName);
  String get findExpertsTitle;
  String get yourJobFeedTitle;
  String get navHome;
  String get navPostJob;
  String get navProfile;
  String get navHistory;
  String get navFeed;
  String get navMyJobs;
  String get navSetup;
  String get appBarHome;
  String get appBarPostNewJob;
  String get appBarMyProfile;
  String get appBarJobHistory;
  String get appBarJobFeed;
  String get appBarMyJobs;
  String get appBarProfileSetup;
  String get themeTooltipLight;
  String get themeTooltipDark;
  String get searchHintProfessionals;
  String get searchHintJobs;
  String get featuredPros;
  String get featuredJobs;
  String get emptyStateProfessionals;
  String get emptyStateJobs;
  String get emptyStateDetails;
  String get refreshButton;
  String get fabPostJob;
  String get fabMyProfile;
  String get fabPostJobTooltip;
  String get fabMyProfileTooltip;
  String get filterOptionsTitle;
  String get filterCategory;
  String get filterLocation;
  String get filterJobStatus;
  String get filterResetButton;
  String get filterApplyButton;
  String get filtersResetSuccess;
  String workerCardJobsDone(int count);
  String workerCardYearsExp(int years);
  String get workerCardHire;
  String get jobCardView;
  String get jobStatusOpen;
  String get jobStatusAssigned;
  String get jobStatusCompleted;
  String get jobStatusUnknown;
  String get jobDateN_A;
  String get generalN_A;
  String get jobUntitled;
  String get jobNoDescription;
  String jobBudgetETB(String amount);
  String get timeAgoJustNow;
  String timeAgoMinute(int minutes);
  String timeAgoHour(int hours);
  String timeAgoDay(int days);
  String timeAgoWeek(int weeks);
  String timeAgoMonth(int months);
  String timeAgoYear(int years);

  // --- WorkerDetail Screen ---
  String workerDetailAbout(String name);
  String get workerDetailSkills;
  String get workerDetailAvailability;
  String workerDetailReviews(int count);
  String get workerDetailLeaveReview;
  String get workerDetailHireNow;
  String get workerDetailWorking;
  String get workerDetailCall;
  String get workerDetailSubmitReview;
  String get workerDetailShareProfileTooltip;
  String get workerDetailAddFavoriteTooltip;
  String get workerDetailRemoveFavoriteTooltip;
  String get workerDetailAvailable;
  String get workerDetailBooked;
  String get workerDetailSelectTime;
  String get workerDetailCancel;
  String get workerDetailAnonymous;
  String get emailNotVerifiedYet;
  String get errorCheckingVerification;
  String get errorResendingEmail;
  String get verificationScreenTitle;
  String get verificationScreenInfo;
  String get checkingStatusButton;
  String get signOutButton;
  String get resendingButton;
  String get resendEmailButton;
  String get checkVerificationButton;

  String get emailVerifiedSuccess;
  String get emailVerificationSent;
  String get workerDetailWriteReviewHint;
  String workerDetailReviewLengthCounter(int currentLength, int maxLength);
  String get workerDetailNoReviews;
  String get workerDetailNoSkills;
  String get workerDetailNoAbout;
  String get workerDetailShowAll;
  String get workerDetailShowLess;
  String get workermoneyempty;

  // --- Notifications ---
  String get notificationTitle;

  // --- Snackbars ---
  String get snackErrorLoading;
  String get snackErrorSubmitting;
  String get snackErrorGeneric;
  String get snackSuccessReviewSubmitted;
  String get snackPleaseLogin;
  String get snackFavoriteAdded;
  String get snackFavoriteRemoved;
  String get snackPhoneNumberCopied;
  String get snackPhoneNumberNotAvailable;
  String get snackErrorCheckFavorites;
  String get snackErrorUpdateFavorites;
  String get snackErrorContactInfo;
  String get snackErrorLoadingProfile;
  String get snackReviewMissing;
  String get snackWorkerNotFound;
  String get createJobSnackbarErrorWorker;
  String get createJobSnackbarErrorUpload;
  String get createJobSnackbarErrorUploadPartial;
  String get createJobSnackbarErrorForm;
  String get createJobSnackbarSuccess;
  String get createJobSnackbarError;
  String createJobSnackbarFileSelected(int count);
  String get createJobSnackbarFileCancelled;
  String get createJobSnackbarErrorPick;
  String get snackErrorCameraNotAvailable;
  String get snackErrorCameraPermission;
  String get snackErrorGalleryPermission;
  String get snackErrorReadFile;
  String get snackSkippingUnknownType;
  String get errorUserNotLoggedIn;
  String get googleSignInCancelled; // Added
  String get googleSignInAccountExists; // Added
  //---- profile ---

  String get profileNotFound;
  String get profileDataUnavailable;
  String get profileEditAvatarHint;
  String get snackSuccessProfileUpdated;
  String get profileStatsTitleWorker;
  String get profileStatsTitleClient;
  String get profileStatJobsCompleted;
  String get profileStatRating;
  String get profileStatExperience;
  String get profileStatReviews;
  String get profileStatJobsPosted;
  String get profileNeedProfileForHistory;
  String get profileJobHistoryTitle;
  String get viewAllButton;
  String get profileNoJobHistory;
  String get workerNameLabel; // You already have clientNameLabel
  String get profileSettingsTitle;
  String get settingsNotificationsTitle;
  String get settingsNotificationsSubtitle;
  String get settingsPaymentTitle;
  String get settingsPaymentSubtitle;
  String get settingsPrivacyTitle;
  String get settingsPrivacySubtitle;
  String get settingsAccountTitle;
  String get settingsAccountSubtitle;
  String get settingsHelpTitle;
  String get settingsHelpSubtitle;
  String get settingsNotificationsContent; // Content for dialogs
  String get settingsPaymentContent;
  String get settingsPrivacyContent;
  String get settingsAccountContent;
  String get settingsHelpContent;
  String get profileEditButton;
  String get dialogEditClientContent;
  String get dialogFeatureUnderDevelopment;
  // --- Dialogs ---

  String get phoneDialogTitle;
  String get phoneDialogCopy;
  String get phoneDialogClose;

  // --- Job Detail Screen ---
  String get jobDetailAppBarTitle;
  String get jobDetailLoading;
  String get jobDetailErrorLoading;
  String get jobDetailStatusLabel;
  String get jobDetailBudgetLabel;
  String get jobDetailLocationLabel;
  String get jobDetailPostedDateLabel;
  String get jobDetailScheduledDateLabel;
  String get jobDetailDescriptionLabel;
  String get jobDetailAttachmentsLabel;
  String get jobDetailNoAttachments;
  String get jobDetailAssignedWorkerLabel;
  String get jobDetailNoWorkerAssigned;
  String get jobDetailViewWorkerProfile;
  String get jobDetailApplicantsLabel;
  String get jobDetailNoApplicantsYet;
  String get jobDetailViewApplicantsButton;
  String get jobDetailActionApply;
  String get jobDetailActionApplying;
  String get jobDetailActionApplied;
  String get jobDetailActionCancelApplication;
  String get jobDetailActionMarkComplete;
  String get jobDetailActionContactClient;
  String get jobDetailActionPayNow;
  String get jobDetailActionMessageWorker;
  String get jobDetailActionLeaveReview;
  String get jobDetailActionPostSimilar;
  String get jobDetailActionShare;
  String get jobDetailDeleteConfirmTitle;
  String get jobDetailDeleteConfirmContent;
  String get jobDetailDeleteConfirmKeep;
  String get jobDetailDeleteConfirmDelete;
  String get jobDetailErrorAssigningWorker;
  String get jobDetailSuccessWorkerAssigned;
  String get jobDetailErrorApplying;
  String get jobDetailSuccessApplied;
  String get jobDetailErrorDeleting;
  String get jobDetailSuccessDeleted;
  String get jobDetailErrorMarkingComplete;
  String get jobDetailSuccessMarkedComplete;
  String get jobDetailFeatureComingSoon;
  String get jobDetailApplicantHireButton;
  String get clientNameLabel;

  // --- Create Job Screen ---
  String get createJobCategoryLabel;
  String get createJobErrorCategory;
  String get createJobErrorSkill;
  String get attachOptionGallery;
  String get paymentScreenTitle;
  String get paymentMethods;
  String get paymentAddMethod;

  String get attachOptionCamera;
  String get attachOptionFile;
  String get attachOptionCancel;
  String get attachTitle;
  String get createJobCategoryHint;
  String get createJobSkillLabel;
  String get createJobSkillHint;
  String get createJobCalendarTitle;
  String get createJobCalendarCancel;
  String get createJobAppBarTitle;
  String get createJobSelectedWorkerSectionTitle;
  String get createJobDetailsSectionTitle;
  String get createJobOptionalSectionTitle;
  String get createJobTitleLabel;
  String get createJobTitleHint;
  String get createJobTitleError;
  String get createJobDescLabel;
  String get createJobDescHint;
  String get createJobDescErrorEmpty;
  String get createJobDescErrorShort;
  String get createJobBudgetLabel;
  String get createJobBudgetHint;
  String get createJobBudgetErrorEmpty;
  String get createJobBudgetErrorNaN;
  String get createJobBudgetErrorPositive;
  String get createJobLocationLabel;
  String get createJobLocationHint;
  String get createJobLocationError;
  String get createJobScheduleLabelOptional;
  String createJobScheduleLabelSet(String date);
  String get createJobScheduleSub;
  String get createJobAttachmentsLabelOptional;
  String get createJobAttachmentsSubAdd;
  String createJobAttachmentsSubCount(int count);
  String get createJobUrgentLabel;
  String get createJobUrgentSub;
  String get createJobButtonPosting;
  String get createJobButtonPost;
  String get registerErrorProfessionRequired; // Added
  String get errorPasswordShort; // Added

  // --- Job Dashboard Screen ---
  String get dashboardTitleDefault;
  String get dashboardTitleWorker;
  String get dashboardTitleClient;
  String get tabWorkerAssigned;
  String get tabWorkerApplied;
  String get tabWorkerActive;
  String get tabClientPosted;
  String get tabClientApplications;
  String get tabClientRequests;
  String get filterAll;
  String get filterOpen;
  String get filterPending;
  String get filterAssigned;
  String get filterAccepted;
  String get filterInProgress;
  String get filterStartedWorking;
  String get filterCompleted;
  String get filterCancelled;
  String get filterRejected;
  String get filterClosed;
  String get emptyStateWorkerAssigned;
  String get emptyStateWorkerApplied;
  String get emptyStateWorkerActive;
  String get emptyStateClientPosted;
  String get emptyStateClientApplications;
  String get emptyStateClientRequests;
  String get emptyStateJobsFilteredTitle;
  String get emptyStateJobsFilteredSubtitle;
  String get emptyStateGeneralSubtitle;
  String get noApplicantsSubtitle;
  String get buttonAccept;
  String get buttonStartWork;
  String get buttonComplete;
  String get buttonViewApplicants;
  String get buttonChatClient;
  String get buttonChatWorker;
  String get buttonPayWorker;
  String get buttonCancelJob;
  String get viewProfileButton;
  String get viewAllApplicantsButton;
  String get buttonChat;
  String get jobAcceptedSuccess;
  String get jobAcceptedError;
  String get jobStartedSuccess;
  String get jobStartedError;
  String get applicantLoadError;
  String applicantsForJob(String jobTitle);
  String get applicantNotFound;
  String get skillsLabel;
  String get aboutLabel;
  String get priceRangeLabel;
  String get experienceLabel;
  String get phoneLabel;
  String get timelinePending;
  String get timelineInProgress;
  String get timelineCompleted;
  String jobsCompleted(int count);
  String yearsExperience(int years);
  String applicantCount(int count);
  String formatTimeAgo(DateTime date);

  // --- Login Screen ---
  String get loginTitle;
  String get loginWelcome;
  String get loginEmailLabel;
  String get loginEmailHint;
  String get loginPasswordLabel;
  String get loginPasswordHint;
  String get loginRememberMe;
  String get loginForgotPassword;
  String get loginButton;
  String get loginNoAccount;
  String get loginSignUpLink;
  String get loginErrorUserNotFound;
  String get loginErrorWrongPassword;
  String get loginErrorInvalidEmail;
  String get loginErrorUserDisabled;
  String get loginErrorTooManyRequests;
  String get loginErrorUnknown;
  String get loginWithGoogle; // Button text
  String get loginErrorGoogleSignIn;
  // General Google Sign In error

  // --- Register Screen ---
  String get registerTitle;
  String get registerSubtitle;
  String get registerUserTypePrompt;
  String get registerUserTypeClient; // Or 'Hiring'
  String get registerUserTypeWorker; // Or 'Professional'
  String get registerProfessionLabel;
  String get registerProfessionHint;
  String get registerFullNameLabel;
  String get registerFullNameHint;
  String get registerPhoneLabel;
  String get registerPhoneHint;
  String get registerConfirmPasswordLabel;
  String get registerConfirmPasswordHint;
  String get registerButton;
  String get registerHaveAccount;
  String get registerSignInLink;
  String get registerErrorPasswordMismatch;
  String get registerErrorWeakPassword;
  String get registerErrorEmailInUse;
  String get verificationScreenHeader;
  String
      get registerErrorInvalidEmailRegister; // Differentiate from login if needed
  String get registerErrorUnknown;
  String get registerWithGoogle; // Button text
  String get registerSuccess;
  String get registerNavigateToSetup;
  String get registerNavigateToHome;

  // --- Forgot Password Screen (if needed) ---
  String get forgotPasswordTitle;
  String get forgotPasswordInstructions;
  String get forgotPasswordButton;
  String get forgotPasswordSuccess;
  String get forgotPasswordError;

  // --- Helper Methods (To be implemented in subclasses) ---
  String getStatusName(String key);
  IconData? getFilterIcon(String key);
  String getFilterName(String key);
  IconData? getEmptyStateIcon(String key);
  String errorFieldRequired(String fieldName);
  String getUserTypeDisplayName(String key);
}

// ===========================================================
//                  English Implementation
// ===========================================================
class AppStringsEn implements AppStrings {
  @override
  Locale get locale => const Locale('en');

  // --- General ---
  @override
  String get appTitle => "FixIt";
  @override
  String get specifyInDescription => 'Specify in Description';
  @override
  String get highContrastTooltip => "High Contrast Mode";
  @override
  String get darkModeTooltip => "Toggle Dark Mode";
  @override
  String get languageToggleTooltip => "Switch Language";
  @override
  String get paymentNoMethod => "No payment method";
  @override
  Map<String, List<String>> get jobCategoriesAndSkills => {
        'Plumbing': [
          'Leak Repair',
          'Pipe Installation',
          'Drain Cleaning',
          'Faucet Fix',
          'Toilet Repair',
          'Water Heater'
        ],
        'Electrical': [
          'Wiring',
          'Outlet Repair',
          'Lighting Installation',
          'Circuit Breaker',
          'Fan Installation',
          'Appliance Repair'
        ],
        'Cleaning': [
          'Home Cleaning',
          'Office Cleaning',
          'Deep Cleaning',
          'Window Washing',
          'Carpet Cleaning'
        ],
        'Painting': [
          'Interior Painting',
          'Exterior Painting',
          'Wall Preparation',
          'Furniture Painting'
        ],
        'Carpentry': [
          'Furniture Assembly',
          'Door Repair',
          'Shelf Installation',
          'Wood Repair'
        ],
        'Gardening': ['Lawn Mowing', 'Planting', 'Weeding', 'Tree Trimming'],
        'Moving': ['Loading/Unloading', 'Packing', 'Furniture Moving'],
        'Handyman': [
          'General Repairs',
          'Mounting TV',
          'Picture Hanging',
          'Minor Fixes'
        ],
        'Other': ['Specify in Description']
      };
  @override
  String get errorInitializationFailed => "Initialization failed";
  @override
  String get errorCouldNotSavePrefs => "Could not save preferences";
  @override
  String get errorConnectivityCheck => "Could not check connectivity";
  @override
  String get errorActionFailed => "Action failed. Please try again.";
  @override
  String get errorCouldNotLaunchUrl => "Could not launch URL.";
  @override
  String get errorCouldNotLaunchDialer => "Could not launch dialer.";
  @override
  String get successPrefsSaved => "Preference saved.";
  @override
  String get successSubscription => "Thank you for subscribing!";
  @override
  String get connectionRestored => "Internet connection restored.";
  @override
  String get noInternet => "No internet connection.";
  @override
  String get retryButton => "Retry";
  @override
  String get errorGeneric => "An error occurred. Please try again.";
  @override
  String get loading => "Loading...";
  @override
  String get generalCancel => "Cancel";
  @override
  String get generalLogout => "Logout";
  @override
  String get emailVerificationSent => "Verification email sent.";
  @override
  String get emailVerifiedSuccess => "Email successfully verified!";
  @override
  String get emailNotVerifiedYet => "Email not verified yet.";
  @override
  String get errorCheckingVerification => "Error checking verification status.";
  @override
  String get verificationScreenTitle => "Email Verification";
  @override
  String get verificationScreenHeader => "Verify Your Email";
  @override
  String get verificationScreenInfo =>
      "Please verify your email to continue registration.";
  @override
  String get checkingStatusButton => "Checking...";
  @override
  String get checkVerificationButton => "Check Verification";
  @override
  String get resendingButton => "Resending...";
  @override
  String get resendEmailButton => "Resend Email";
  @override
  String get signOutButton => "Sign Out";
  @override
  String get errorResendingEmail => "Error resending verification email.";

  @override
  String get clear => 'Clear';
  @override
  String get ok => 'OK';
  @override
  String get notAvailable => "N/A";
  @override
  String get notSet => "Not Set";

  // --- HomeScreen ---
  @override
  String helloUser(String userName) => "Hello, $userName!";
  @override
  String get findExpertsTitle => "Find Experts";
  @override
  String get yourJobFeedTitle => "Your Job Feed";
  @override
  String get navHome => "Home";
  @override
  String get navPostJob => "Post Job";
  @override
  String get navProfile => "Profile";
  @override
  String get navHistory => "History";
  @override
  String get navFeed => "Feed";
  @override
  String get navMyJobs => "My Jobs";
  @override
  String get navSetup => "Setup";
  @override
  String get appBarHome => "Home";
  @override
  String get appBarPostNewJob => "Post New Job";
  @override
  String get appBarMyProfile => "My Profile";
  @override
  String get appBarJobHistory => "Job History";
  @override
  String get appBarJobFeed => "Job Feed";
  @override
  String get appBarMyJobs => "My Jobs";
  @override
  String get appBarProfileSetup => "Profile Setup";
  @override
  String get themeTooltipLight => "Switch to Light Mode";
  @override
  String get themeTooltipDark => "Switch to Dark Mode";
  @override
  String get searchHintProfessionals => "Search Professionals, Skills...";
  @override
  String get searchHintJobs => "Search Jobs, Keywords...";
  @override
  String get featuredPros => "⭐ Top Rated Pros";
  @override
  String get featuredJobs => "🚀 Recent Open Jobs";
  @override
  String get emptyStateProfessionals => "No Professionals Found";
  @override
  String get emptyStateJobs => "No Jobs Match Your Criteria";
  @override
  String get emptyStateDetails =>
      "Try adjusting your search terms or clearing the filters.";
  @override
  String get refreshButton => "Refresh";
  @override
  String get fabPostJob => "Post New Job";
  @override
  String get fabMyProfile => "My Profile";
  @override
  String get fabPostJobTooltip => "Create a new job posting";
  @override
  String get fabMyProfileTooltip => "View or edit your professional profile";
  @override
  String get filterOptionsTitle => "Filter Options";
  @override
  String get filterCategory => "Category / Profession";
  @override
  String get filterLocation => "Location";
  @override
  String get filterJobStatus => "Job Status";
  @override
  String get filterResetButton => "Reset";
  @override
  String get filterApplyButton => "Apply Filters";
  @override
  String get filtersResetSuccess => "Filters reset";
  @override
  String workerCardJobsDone(int count) => "$count Jobs Done";
  @override
  String workerCardYearsExp(int years) => "$years yrs Exp";
  @override
  String get workerCardHire => "Hire";
  @override
  String get jobCardView => "View Details";
  @override
  String get jobStatusOpen => "Open";
  @override
  String get jobStatusAssigned => "Assigned";
  @override
  String get jobStatusCompleted => "Completed";
  @override
  String get jobStatusUnknown => "Unknown";
  @override
  String get jobDateN_A => "Date N/A";
  @override
  String get generalN_A => "N/A";
  @override
  String get jobUntitled => "Untitled Job";
  @override
  String get jobNoDescription => "No description provided.";
  @override
  String jobBudgetETB(String amount) => "$amount ETB";
  @override
  String get timeAgoJustNow => "Just now";
  @override
  String timeAgoMinute(int minutes) => "${minutes}m ago";
  @override
  String timeAgoHour(int hours) => "${hours}h ago";
  @override
  String timeAgoDay(int days) => "${days}d ago";
  @override
  String timeAgoWeek(int weeks) => "${weeks}w ago";
  @override
  String timeAgoMonth(int months) => "${months}mo ago";
  @override
  String timeAgoYear(int years) => "${years}y ago";

  // --- WorkerDetail Screen ---
  @override
  String workerDetailAbout(String name) => "About $name";
  @override
  String get workerDetailSkills => "Skills";
  @override
  String get workerDetailAvailability => "Availability";
  @override
  String workerDetailReviews(int count) => "Reviews ($count)";
  @override
  String get workerDetailLeaveReview => "Leave a Review";
  @override
  String get workerDetailHireNow => "Hire Now";
  @override
  String get workerDetailWorking => "Working";
  @override
  String get workerDetailCall => "Call";
  @override
  String get workerDetailSubmitReview => "Submit Review";
  @override
  String get workerDetailShareProfileTooltip => "Share Profile";
  @override
  String get workerDetailAddFavoriteTooltip => "Add Favorite";
  @override
  String get workerDetailRemoveFavoriteTooltip => "Remove Favorite";
  @override
  String get workerDetailAvailable => "Available";
  @override
  String get workerDetailBooked => "Booked";
  @override
  String get workerDetailSelectTime => "Select Time Slot";
  @override
  String get workerDetailCancel => "Cancel";
  @override
  String get workerDetailAnonymous => "Anonymous";
  @override
  String get profileNotFound => "Profile not found.";
  @override
  String get profileDataUnavailable => "Profile data unavailable.";
  @override
  String get profileEditAvatarHint => "Tap to edit profile avatar";
  @override
  String get snackSuccessProfileUpdated => "Profile updated successfully!";
  @override
  String get profileStatsTitleWorker => "Profile Stats";
  @override
  String get profileStatsTitleClient => "Profile Stats";
  @override
  String get profileStatJobsCompleted => "Jobs Completed";
  @override
  String get profileStatRating => "Rating";
  @override
  String get profileStatExperience => "Experience";
  @override
  String get profileStatReviews => "Reviews";
  @override
  String get profileStatJobsPosted => "Jobs Posted";
  @override
  String get profileNeedProfileForHistory =>
      "You need a profile for job history.";
  @override
  String get profileJobHistoryTitle => "Job History";
  @override
  String get viewAllButton => "View All";
  @override
  String get profileNoJobHistory => "No job history found.";
  @override
  String get workerNameLabel => "Worker Name";
  @override
  String get profileSettingsTitle => "Settings";
  @override
  String get settingsNotificationsTitle => "Notifications";
  @override
  String get settingsNotificationsSubtitle => "Notifications settings";
  @override
  String get settingsPaymentTitle => "Payment";
  @override
  String get settingsPaymentSubtitle => "Payment settings";
  @override
  String get settingsPrivacyTitle => "Privacy";
  @override
  String get settingsPrivacySubtitle => "Privacy settings";
  @override
  String get settingsAccountTitle => "Account";
  @override
  String get settingsAccountSubtitle => "Account settings";
  @override
  String get settingsHelpTitle => "Help";
  @override
  String get settingsHelpSubtitle => "Help and support";
  @override
  String get settingsNotificationsContent => "Notifications content";
  @override
  String get settingsPaymentContent => "Payment content";
  @override
  String get settingsPrivacyContent => "Privacy content";
  @override
  String get settingsAccountContent => "Account content";
  @override
  String get settingsHelpContent => "Help content";
  @override
  String get profileEditButton => "Edit Profile";
  @override
  String get dialogEditClientContent => "Edit client content";
  @override
  String get dialogFeatureUnderDevelopment => "Feature under development";
  @override
  String get workerDetailWriteReviewHint => "Share your experience...";
  @override
  String workerDetailReviewLengthCounter(int currentLength, int maxLength) =>
      "$currentLength/$maxLength";
  @override
  String get workerDetailNoReviews => "No reviews yet.";
  @override
  String get workerDetailNoSkills => "No skills listed.";
  @override
  String get workerDetailNoAbout => "No details provided.";
  @override
  String get workerDetailShowAll => "Show All";
  @override
  String get workerDetailShowLess => "Show Less";
  @override
  String get workermoneyempty => "Not set";

  // --- Notifications ---
  @override
  String get notificationTitle => "Notifications";

  // --- Snackbars ---
  @override
  String get snackErrorLoading => "Error loading data.";
  @override
  String get snackErrorSubmitting => "Failed to submit.";
  @override
  String get snackErrorGeneric => "An error occurred. Please try again.";
  @override
  String get snackSuccessReviewSubmitted => "Review submitted successfully!";
  @override
  String get snackPleaseLogin => "Please log in to continue.";
  @override
  String get snackFavoriteAdded => "Added to favorites!";
  @override
  String get snackFavoriteRemoved => "Removed from favorites";
  @override
  String get snackPhoneNumberCopied => "Phone number copied!";
  @override
  String get snackPhoneNumberNotAvailable => "Phone number not available.";
  @override
  String get snackErrorCheckFavorites => "Error checking favorites.";
  @override
  String get snackErrorUpdateFavorites => "Could not update favorites.";
  @override
  String get snackErrorContactInfo => "Error getting contact info.";
  @override
  String get snackErrorLoadingProfile => "Error loading your profile.";
  @override
  String get snackReviewMissing => "Please provide both a rating and comment.";
  @override
  String get snackWorkerNotFound => "Worker profile not found.";
  @override
  String get createJobSnackbarErrorWorker =>
      'Error loading worker details. Please try again.';
  @override
  String get createJobSnackbarErrorUpload =>
      'Error uploading attachments. Please try again.';
  @override
  String get createJobSnackbarErrorUploadPartial =>
      'Some attachments failed to upload.';
  @override
  String get createJobSnackbarErrorForm => 'Please fix the errors in the form.';
  @override
  String get createJobSnackbarSuccess => 'Job posted successfully!';
  @override
  String get createJobSnackbarError =>
      'Failed to create job. Please try again.';
  @override
  String createJobSnackbarFileSelected(int count) => '$count file(s) selected.';
  @override
  String get createJobSnackbarFileCancelled => 'File selection cancelled.';
  @override
  String get createJobSnackbarErrorPick =>
      'Error picking files. Please try again.';
  @override
  String get snackErrorCameraNotAvailable =>
      'Camera not available on this device.';
  @override
  String get snackErrorCameraPermission =>
      'Camera permission denied. Please enable it in settings.';
  @override
  String get snackErrorGalleryPermission =>
      'Gallery permission denied. Please enable it in settings.';
  @override
  String get snackErrorReadFile => 'Failed to read file data.';
  @override
  String get snackSkippingUnknownType => 'Skipping unknown file type.';
  @override
  String get errorUserNotLoggedIn => "User not logged in.";
  @override
  String get googleSignInCancelled => "Google Sign-In cancelled.";
  @override
  String get googleSignInAccountExists =>
      "Account exists with different credentials. Try logging in differently.";

  // --- Dialogs ---
  @override
  String get phoneDialogTitle => "Contact Number";
  @override
  String get phoneDialogCopy => "Copy Number";
  @override
  String get phoneDialogClose => "Close";

  // --- Job Detail Screen ---
  @override
  String get jobDetailAppBarTitle => "Job Details";
  @override
  String get jobDetailLoading => "Loading Job Details...";
  @override
  String get jobDetailErrorLoading => "Error loading job details.";
  @override
  String get jobDetailStatusLabel => "Status";
  @override
  String get jobDetailBudgetLabel => "Budget";
  @override
  String get jobDetailLocationLabel => "Location";
  @override
  String get jobDetailPostedDateLabel => "Posted On";
  @override
  String get jobDetailScheduledDateLabel => "Scheduled For";
  @override
  String get jobDetailDescriptionLabel => "Description";
  @override
  String get jobDetailAttachmentsLabel => "Attachments";
  @override
  String get jobDetailNoAttachments => "No attachments provided.";
  @override
  String get jobDetailAssignedWorkerLabel => "Assigned Professional";
  @override
  String get jobDetailNoWorkerAssigned => "No professional assigned yet.";
  @override
  String get jobDetailViewWorkerProfile => "View Profile";
  @override
  String get jobDetailApplicantsLabel => "Applicants";
  @override
  String get jobDetailNoApplicantsYet => "No applications received yet.";
  @override
  String get jobDetailViewApplicantsButton => "View Applicants";
  @override
  String get jobDetailActionApply => "Apply for This Job";
  @override
  String get jobDetailActionApplying => "Applying...";
  @override
  String get jobDetailActionApplied => "Application Submitted";
  @override
  String get jobDetailActionCancelApplication => "Cancel Application";
  @override
  String get jobDetailActionMarkComplete => "Mark as Completed";
  @override
  String get jobDetailActionContactClient => "Contact Client";
  @override
  String get jobDetailActionPayNow => "Proceed to Payment";
  @override
  String get jobDetailActionMessageWorker => "Message Professional";
  @override
  String get jobDetailActionLeaveReview => "Leave a Review";
  @override
  String get jobDetailActionPostSimilar => "Post Similar Job";
  @override
  String get jobDetailActionShare => "Share This Job";
  @override
  String get jobDetailDeleteConfirmTitle => "Delete Job";
  @override
  String get jobDetailDeleteConfirmContent =>
      "Are you sure you want to permanently delete this job posting?";
  @override
  String get jobDetailDeleteConfirmKeep => "Keep Job";
  @override
  String get jobDetailDeleteConfirmDelete => "Delete";
  @override
  String get jobDetailErrorAssigningWorker => "Error assigning worker.";
  @override
  String get jobDetailSuccessWorkerAssigned => "Worker assigned successfully!";
  @override
  String get jobDetailErrorApplying => "Error submitting application.";
  @override
  String get jobDetailSuccessApplied => "Application submitted successfully!";
  @override
  String get jobDetailErrorDeleting => "Error deleting job.";
  @override
  String get jobDetailSuccessDeleted => "Job deleted successfully.";
  @override
  String get jobDetailErrorMarkingComplete => "Error marking job as complete.";
  @override
  String get jobDetailSuccessMarkedComplete => "Job marked as complete!";
  @override
  String get jobDetailFeatureComingSoon => "Feature coming soon!";
  @override
  String get jobDetailApplicantHireButton => "Hire";
  @override
  String get clientNameLabel => "Client";
/*************  ✨ Windsurf Command ⭐  *************/
  @override
  String get paymentScreenTitle => "Manage Payment Methods";
  @override
  String get paymentMethods => "Payment Methods";
  @override
  String get paymentAddMethod => "Add Method";
/*******  aec637b2-415f-4958-8219-98ddf61e3cc4  *******/

  // --- Create Job Screen ---
  @override
  String get createJobCategoryLabel => 'Category';
  @override
  String get createJobCategoryHint => 'Select job category';
  @override
  String get createJobErrorCategory => 'Please select a category.';
  @override
  String get createJobSkillLabel => 'Specific Skill / Task';
  @override
  String get createJobSkillHint => 'Select required skill';
  @override
  String get createJobErrorSkill => 'Please select a skill/task.';
  @override
  String get attachOptionGallery => 'Choose from Gallery';
  @override
  String get attachOptionCamera => 'Take Photo';
  @override
  String get attachOptionFile => 'Browse Files';
  @override
  String get attachOptionCancel => 'Cancel';
  @override
  String get attachTitle => 'Add Attachment';
  @override
  String get createJobCalendarTitle => 'Select Job Date';
  @override
  String get createJobCalendarCancel => 'Cancel';
  @override
  String get createJobAppBarTitle => 'Create New Job';
  @override
  String get createJobSelectedWorkerSectionTitle => 'Selected Worker';
  @override
  String get createJobDetailsSectionTitle => 'Job Details';
  @override
  String get createJobOptionalSectionTitle => 'Optional Details';
  @override
  String get createJobTitleLabel => 'Job Title';
  @override
  String get createJobTitleHint => 'e.g., Fix leaky faucet';
  @override
  String get createJobTitleError => 'Please enter a job title.';
  @override
  String get createJobDescLabel => 'Description';
  @override
  String get createJobDescHint =>
      'Provide details about the job... (min 20 chars)';
  @override
  String get createJobDescErrorEmpty => 'Please enter a description.';
  @override
  String get createJobDescErrorShort =>
      'Description must be at least 20 characters long.';
  @override
  String get createJobBudgetLabel => 'Budget (ETB)';
  @override
  String get createJobBudgetHint => 'e.g., 500';
  @override
  String get createJobBudgetErrorEmpty => 'Please enter a budget amount.';
  @override
  String get createJobBudgetErrorNaN =>
      'Please enter a valid number for the budget.';
  @override
  String get createJobBudgetErrorPositive =>
      'Budget must be a positive amount.';
  @override
  String get createJobLocationLabel => 'Location';
  @override
  String get createJobLocationHint => 'e.g., Bole, Addis Ababa';
  @override
  String get createJobLocationError => 'Please enter the job location.';
  @override
  String get createJobScheduleLabelOptional => 'Schedule Date (Optional)';
  @override
  String createJobScheduleLabelSet(String date) => 'Scheduled for: $date';
  @override
  String get createJobScheduleSub => 'Tap to select a preferred date';
  @override
  String get createJobAttachmentsLabelOptional => 'Attachments (Optional)';
  @override
  String get createJobAttachmentsSubAdd => 'Tap to add photos or documents';
  @override
  String createJobAttachmentsSubCount(int count) => '$count file(s) attached';
  @override
  String get createJobUrgentLabel => 'Mark as Urgent';
  @override
  String get createJobUrgentSub => 'Urgent jobs may get quicker responses';
  @override
  String get createJobButtonPosting => 'POSTING...';
  @override
  String get createJobButtonPost => 'POST JOB';
  @override
  String get registerErrorProfessionRequired => "Please enter your profession.";
  @override
  String get errorPasswordShort => "Password must be at least 6 characters.";

  // --- Job Dashboard Screen ---
  @override
  String get dashboardTitleDefault => "Dashboard";
  @override
  String get dashboardTitleWorker => "My Work Dashboard";
  @override
  String get dashboardTitleClient => "My Jobs Dashboard";
  @override
  String get tabWorkerAssigned => "ASSIGNED TO ME";
  @override
  String get tabWorkerApplied => "MY APPLICATIONS";
  @override
  String get tabWorkerActive => "ACTIVE/DONE";
  @override
  String get tabClientPosted => "MY POSTINGS";
  @override
  String get tabClientApplications => "APPLICANTS";
  @override
  String get tabClientRequests => "MY REQUESTS";
  @override
  String get filterAll => "All";
  @override
  String get filterOpen => "Open";
  @override
  String get filterPending => "Pending";
  @override
  String get filterAssigned => "Assigned";
  @override
  String get filterAccepted => "Accepted";
  @override
  String get filterInProgress => "In Progress";
  @override
  String get filterStartedWorking => "Working";
  @override
  String get filterCompleted => "Completed";
  @override
  String get filterCancelled => "Cancelled";
  @override
  String get filterRejected => "Rejected";
  @override
  String get filterClosed => "Closed";
  @override
  String get emptyStateWorkerAssigned => "No Jobs Assigned Yet";
  @override
  String get emptyStateWorkerApplied => "You Haven't Applied to Any Jobs";
  @override
  String get emptyStateWorkerActive => "No Active or Completed Work Yet";
  @override
  String get emptyStateClientPosted => "You Haven't Posted Any Jobs";
  @override
  String get emptyStateClientApplications => "No Applications Received Yet";
  @override
  String get emptyStateClientRequests =>
      "You Haven't Requested Any Jobs Directly";
  @override
  String get emptyStateJobsFilteredTitle => "No Jobs Match Filter";
  @override
  String get emptyStateJobsFilteredSubtitle =>
      "Try adjusting the status filter above.";
  @override
  String get emptyStateGeneralSubtitle => "Check back later or refresh.";
  @override
  String get noApplicantsSubtitle =>
      "When workers apply, they will show up here.";
  @override
  String get buttonAccept => "Accept";
  @override
  String get buttonStartWork => "Start Work";
  @override
  String get buttonComplete => "Complete";
  @override
  String get buttonViewApplicants => "View Applicants";
  @override
  String get buttonChatClient => "Chat Client";
  @override
  String get buttonChatWorker => "Chat Worker";
  @override
  String get buttonPayWorker => "Pay Worker";
  @override
  String get buttonCancelJob => "Cancel Job";
  @override
  String get viewProfileButton => "View Profile";
  @override
  String get viewAllApplicantsButton => "View All";
  @override
  String get buttonChat => "Chat";
  @override
  String get jobAcceptedSuccess => "Job accepted successfully!";
  @override
  String get jobAcceptedError => "Failed to accept job.";
  @override
  String get jobStartedSuccess => "Work started!";
  @override
  String get jobStartedError => "Failed to update status to 'started'.";
  @override
  String get applicantLoadError => "Error loading applicants.";
  @override
  String applicantsForJob(String jobTitle) => "Applicants for: $jobTitle";
  @override
  String get applicantNotFound => "Applicant not found";
  @override
  String get skillsLabel => "Skills:";
  @override
  String get aboutLabel => "About:";
  @override
  String get priceRangeLabel => "Price Range";
  @override
  String get experienceLabel => "Experience";
  @override
  String get phoneLabel => "Phone";
  @override
  String get timelinePending => "Pending";
  @override
  String get timelineInProgress => "In Progress";
  @override
  String get timelineCompleted => "Completed";

  // --- Login Screen ---
  @override
  String get loginTitle => "Welcome Back!";
  @override
  String get loginWelcome => "Log in to continue";
  @override
  String get loginEmailLabel => "Email";
  @override
  String get loginEmailHint => "Enter your email";
  @override
  String get loginPasswordLabel => "Password";
  @override
  String get loginPasswordHint => "Enter your password";
  @override
  String get loginRememberMe => "Remember Me";
  @override
  String get loginForgotPassword => "Forgot Password?";
  @override
  String get loginButton => "LOG IN";
  @override
  String get loginNoAccount => "Don't have an account? ";
  @override
  String get loginSignUpLink => "Sign Up";
  @override
  String get loginErrorUserNotFound => "No user found for that email.";
  @override
  String get loginErrorWrongPassword => "Wrong password provided.";
  @override
  String get loginErrorInvalidEmail => "The email address is badly formatted.";
  @override
  String get loginErrorUserDisabled => "This user account has been disabled.";
  @override
  String get loginErrorTooManyRequests =>
      "Too many login attempts. Please try again later.";
  @override
  String get loginErrorUnknown =>
      "Login failed. Please check your credentials.";
  @override
  String get loginWithGoogle => "Sign in with Google";

  @override
  String get loginErrorGoogleSignIn =>
      "Google Sign-In failed. Please try again.";

  // --- Register Screen ---
  @override
  String get registerTitle => "Create Account";
  @override
  String get registerSubtitle =>
      "Join our community of clients and professionals";
  @override
  String get registerUserTypePrompt => "I am a:";
  @override
  String get registerUserTypeClient => "Client (Hiring)";
  @override
  String get registerUserTypeWorker => "Professional (Worker)";
  @override
  String get registerProfessionLabel => "Your Profession";
  @override
  String get registerProfessionHint => "e.g., Plumber, Electrician";
  @override
  String get registerFullNameLabel => "Full Name";
  @override
  String get registerFullNameHint => "Enter your full name";
  @override
  String get registerPhoneLabel => "Phone Number";
  @override
  String get registerPhoneHint => "Enter your phone number";
  @override
  String get registerConfirmPasswordLabel => "Confirm Password";
  @override
  String get registerConfirmPasswordHint => "Re-enter your password";
  @override
  String get registerButton => "CREATE ACCOUNT";
  @override
  String get registerHaveAccount => "Already have an account? ";
  @override
  String get registerSignInLink => "Sign In";
  @override
  String get registerErrorPasswordMismatch => "Passwords do not match.";
  @override
  String get registerErrorWeakPassword => "The password provided is too weak.";
  @override
  String get registerErrorEmailInUse =>
      "An account already exists for that email.";
  @override
  String get registerErrorInvalidEmailRegister =>
      "The email address is badly formatted.";
  @override
  String get registerErrorUnknown => "Registration failed. Please try again.";
  @override
  String get registerWithGoogle => "Sign up with Google";
  @override
  String get registerSuccess => "Registration successful!";
  @override
  String get registerNavigateToSetup => "Navigating to professional setup...";
  @override
  String get registerNavigateToHome => "Navigating to home...";

  // --- Forgot Password Screen ---
  @override
  String get forgotPasswordTitle => "Reset Password";
  @override
  String get forgotPasswordInstructions =>
      "Enter your email address below and we'll send you a link to reset your password.";
  @override
  String get forgotPasswordButton => "Send Reset Link";
  @override
  String get forgotPasswordSuccess =>
      "Password reset email sent! Please check your inbox.";
  @override
  String get forgotPasswordError =>
      "Error sending reset email. Please check the address and try again.";

  // --- Helper Method Implementations ---
  @override
  String getStatusName(String key) {
    switch (key.toLowerCase()) {
      case 'open':
        return filterOpen;
      case 'pending':
        return filterPending;
      case 'assigned':
        return filterAssigned;
      case 'accepted':
        return filterAccepted;
      case 'in_progress':
        return filterInProgress;
      case 'started working':
        return filterStartedWorking;
      case 'completed':
        return filterCompleted;
      case 'cancelled':
        return filterCancelled;
      case 'rejected':
        return filterRejected;
      case 'closed':
        return filterClosed;
      default:
        return key.toUpperCase();
    }
  }

  @override
  IconData? getFilterIcon(String key) {
    switch (key.toLowerCase()) {
      case 'all':
        return Icons.list_alt_rounded;
      case 'open':
        return Icons.lock_open_rounded;
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'assigned':
        return Icons.assignment_ind_outlined;
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'in_progress':
        return Icons.construction_rounded;
      case 'started working':
        return Icons.play_circle_outline_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'rejected':
        return Icons.thumb_down_alt_outlined;
      case 'closed':
        return Icons.lock_outline_rounded;
      default:
        return null;
    }
  }

  @override
  String getFilterName(String key) => getStatusName(key);
  @override
  IconData? getEmptyStateIcon(String key) {
    if (key == emptyStateWorkerAssigned) return Icons.assignment_late_outlined;
    if (key == emptyStateWorkerApplied)
      return Icons.playlist_add_check_circle_outlined;
    if (key == emptyStateWorkerActive) return Icons.construction_rounded;
    if (key == emptyStateClientPosted) return Icons.post_add_rounded;
    if (key == emptyStateClientApplications) return Icons.people_alt_outlined;
    if (key == emptyStateClientRequests) return Icons.request_page_outlined;
    return Icons.search_off_rounded;
  }

  @override
  String yearsExperience(int years) =>
      "$years year${years == 1 ? '' : 's'} Exp";
  @override
  String applicantCount(int count) =>
      "$count Applicant${count == 1 ? '' : 's'}";
  @override
  String jobsCompleted(int count) => "$count Jobs Done";
  @override
  String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60) return timeAgoJustNow;
    if (difference.inMinutes < 60) return timeAgoMinute(difference.inMinutes);
    if (difference.inHours < 24) return timeAgoHour(difference.inHours);
    if (difference.inDays < 7) return timeAgoDay(difference.inDays);
    if (difference.inDays < 30)
      return timeAgoWeek((difference.inDays / 7).floor());
    if (difference.inDays < 365)
      return timeAgoMonth((difference.inDays / 30).floor());
    return timeAgoYear((difference.inDays / 365).floor());
  }

  @override
  String errorFieldRequired(String fieldName) => "Please enter $fieldName.";
  @override
  String getUserTypeDisplayName(String key) {
    switch (key) {
      case 'registerUserTypeClient':
        return registerUserTypeClient;
      case 'registerUserTypeWorker':
        return registerUserTypeWorker;
      default:
        return key;
    }
  }
}

// ===========================================================
//                 Amharic Implementation
// ===========================================================
class AppStringsAm implements AppStrings {
  @override
  Locale get locale => const Locale('am');

  // --- Implement ALL abstract members ---

  // General
  @override
  String get appTitle => "FixIt"; // Translate as needed
  @override
  String get specifyInDescription => 'በመግለጫው ውስጥ ይግለጹ';
  @override
  String get highContrastTooltip => "ከፍተኛ ንፅፅር";
  @override
  String get darkModeTooltip => "ጨለማ ሁናቴ";
  @override
  String get languageToggleTooltip => "ቋንቋ ቀይር";
  @override
  Map<String, List<String>> get jobCategoriesAndSkills => {
        'የቧንቧ ስራ': [
          'የውሃ ጠብታ ጥገና',
          'የቧንቧ ዝርጋታ',
          'የፍሳሽ ማጽዳት',
          'የውሃ ቧንቧ ጥገና',
          'የሽንት ቤት ጥገና',
          'የውሃ ማሞቂያ'
        ],
        'የኤሌክትሪክ ስራ': [
          'የሽቦ ዝርጋታ',
          'የሶኬት ጥገና',
          'የመብራት ተከላ',
          'ሰርኪዩት ብሬከር',
          'የማራገቢያ ተከላ',
          'የቤት እቃ ጥገና'
        ],
        'ጽዳት': ['የቤት ጽዳት', 'የቢሮ ጽዳት', 'ጥልቅ ጽዳት', 'የመስኮት ጽዳት', 'ምንጣፍ ጽዳት'],
        'ቀለም ቅብ': ['የቤት ውስጥ ቀለም', 'የውጭ ቀለም', 'የግድግዳ ዝግጅት', 'የቤት እቃ ቀለም'],
        'የእንጨት ስራ': ['የቤት እቃ ገጣጠም', 'የበር ጥገና', 'የመደርደሪያ ተከላ', 'የእንጨት ጥገና'],
        'አትክልተኝነት': ['የሣር ማጨድ', 'መትከል', 'አረም መንቀል', 'የዛፍ ቅርንጫፍ መቁረጥ'],
        'ዕቃ ማጓጓዝ': ['መጫን/ማውረድ', 'ማሸግ', 'የቤት ዕቃ ማንቀሳቀስ'],
        'የእጅ ባለሙያ': ['አጠቃላይ ጥገና', 'ቴሌቪዥን መስቀል', 'ፎቶ መስቀል', 'ጥቃቅን ጥገናዎች'],
        'ሌላ': ['በመግለጫው ውስጥ ይግለጹ']
      };
  @override
  String get errorInitializationFailed => "ማስጀመር አልተሳካም";
  @override
  String get profileNotFound => "ፕሮፋይል አልተገኘም";
  @override
  String get profileDataUnavailable => "ፕሮፋይል መረጃ አልተገኘም";
  @override
  String get profileEditAvatarHint => "አበባዬን አስቀጥል";
  @override
  String get snackSuccessProfileUpdated => "ፕሮፋይሉ ተካፈል";
  @override
  String get profileStatsTitleWorker => "የአስተማሪ አስታቲክስ";
  @override
  String get profileStatsTitleClient => "የአገልጋይ አስታቲክስ";
  @override
  String get profileStatJobsCompleted => "የተጠናቀቀት ስራዎች";
  @override
  String get profileStatRating => "ምርጫ";
  @override
  String get profileStatExperience => "አስተማሪነት";
  @override
  String get profileStatReviews => "አስተያየት";
  @override
  String get profileStatJobsPosted => "የተሳተረተቀበት ስራዎች";
  @override
  String get profileNeedProfileForHistory => "ለስራ ታሪክ ፕሮፋይል ያስፈልጋል";
  @override
  String get profileJobHistoryTitle => "ስራ ታሪክ";
  @override
  String get viewAllButton => "ሁሉን ይመልከቱ";
  @override
  String get profileNoJobHistory => "ስራ ታሪክ የለም";
  @override
  String get workerNameLabel => "የአስተማሪ ስም";
  @override
  String get profileSettingsTitle => "ማስቀመጣዎች";
  @override
  String get settingsNotificationsTitle => "ማስታወቂያ";
  @override
  String get settingsNotificationsSubtitle => "አንታ ማስታወቂያዎችን አስቀጣል";
  @override
  String get settingsPaymentTitle => "ክፍያ";
  @override
  String get settingsPaymentSubtitle => "አንታ ክፍያ በኩል አስቀጣል";
  @override
  String get settingsPrivacyTitle => "ልማት";
  @override
  String get settingsPrivacySubtitle => "አንታ ልማትን አስቀጣል";
  @override
  String get settingsAccountTitle => "አካውንት";
  @override
  String get settingsAccountSubtitle => "አንታ አካውንትን አስቀጣል";
  @override
  String get settingsHelpTitle => "እርዳታ";
  @override
  String get settingsHelpSubtitle => "አንታ እርዳታን አስቀጣል";
  @override
  String get settingsNotificationsContent => "ማስታወቂያዎችን አስቀጣል";
  @override
  String get settingsPaymentContent => "ክፍያዎችን አስቀጣል";
  @override
  String get settingsPrivacyContent => "ልማትን አስቀጣል";
  @override
  String get settingsAccountContent => "አካውንትን አስቀጣል";
  @override
  String get settingsHelpContent => "እርዳታን አስቀጣል";
  @override
  String get profileEditButton => "አስቀጥል";
  @override
  String get dialogEditClientContent => "አገልጋይ አስቀጥል";
  @override
  String get dialogFeatureUnderDevelopment => "ይህ ቀላል በቅርብ እንደሚቀርብ ነው።";
  @override
  String get errorCouldNotSavePrefs => "ምርጫዎችን ማስቀመጥ አልተቻለም";
  @override
  String get errorConnectivityCheck => "ግንኙነትን ማረጋገጥ አልተቻለም";
  @override
  String get errorActionFailed => "እርምጃው አልተሳካም። እባክዎ እንደገና ይሞክሩ.";
  @override
  String get errorCouldNotLaunchUrl => "ዩአርኤል መክፈት አልተቻለም።";
  @override
  String get errorCouldNotLaunchDialer => "መደወያ መክፈት አልተቻለም።";
  @override
  String get successPrefsSaved => "ምርጫ ተቀምጧል።";
  @override
  String get successSubscription => "ስለተመዘገቡ እናመሰግናለን!";
  @override
  String get connectionRestored => "የበይነመረብ ግንኙነት ተመልሷል።";
  @override
  String get noInternet => "የበይነመረብ ግንኙነት የለም።";
  @override
  String get retryButton => "እንደገና ሞክር";
  @override
  String get errorGeneric => "ስህተት ተከስቷል። እባክዎ እንደገና ይሞክሩ።";
  @override
  String get loading => "በመጫን ላይ...";
  @override
  String get generalCancel => "ይቅር";
  @override
  String get generalLogout => "ውጣ";

  @override
  String get emailVerificationSent => 'ኢሜል ማረጋገጫ ተልኳል።';
  @override
  String get emailVerifiedSuccess => 'ኢሜል ተረጋግጧል።';
  @override
  String get emailNotVerifiedYet => 'ኢሜል አልተረጋገጠም።';
  @override
  String get errorCheckingVerification => 'ማረጋገጫውን ማረጋግጥ አልተቻለም።';
  @override
  String get errorResendingEmail => 'ኢሜል እንደገና ማላክ አልተቻለም።';
  @override
  String get verificationScreenTitle => 'የማረጋገጫ ገጽ';
  @override
  String get verificationScreenHeader => 'እባኮትን እንደገና ያረጋግጡ።';
  @override
  String get verificationScreenInfo => 'ኢሜልዎ ላይ የማረጋገጫ መልእክት ተልኳል።';
  @override
  String get checkingStatusButton => 'ሁኔታ ማረጋገጥ...';
  @override
  String get checkVerificationButton => 'ማረጋገጫ ያረጋግጡ።';
  @override
  String get resendingButton => 'እንደገና ማላክ...';
  @override
  String get resendEmailButton => 'ኢሜል እንደገና ላክ';
  @override
  String get signOutButton => 'ውጣ';

  @override
  String get clear => 'አጥፋ';
  @override
  String get ok => 'እሺ';
  @override
  String get notAvailable => "የለም";
  @override
  String get notSet => "አልተቀመጠም";

  // HomeScreen
  @override
  String helloUser(String userName) => "ሰላም, $userName!";
  @override
  String get findExpertsTitle => "ባለሙያዎችን ያግኙ";
  @override
  String get yourJobFeedTitle => "የእርስዎ የስራ ዝርዝር";
  @override
  String get navHome => "መነሻ";
  @override
  String get navPostJob => "ስራ ለጥፍ";
  @override
  String get navProfile => "መገለጫ";
  @override
  String get navHistory => "ታሪክ";
  @override
  String get navFeed => "ዝርዝር";
  @override
  String get navMyJobs => "የእኔ ስራዎች";
  @override
  String get navSetup => "ማዋቀር";
  @override
  String get appBarHome => "መነሻ";
  @override
  String get appBarPostNewJob => "አዲስ ስራ ለጥፍ";
  @override
  String get appBarMyProfile => "የእኔ መገለጫ";
  @override
  String get appBarJobHistory => "የስራ ታሪክ";
  @override
  String get appBarJobFeed => "የስራ ዝርዝር";
  @override
  String get appBarMyJobs => "የእኔ ስራዎች";
  @override
  String get appBarProfileSetup => "የመገለጫ ማዋቀር";
  @override
  String get themeTooltipLight => "ወደ ቀላል ገጽታ ቀይር";
  @override
  String get themeTooltipDark => "ወደ ጨለማ ገጽታ ቀይር";
  @override
  String get searchHintProfessionals => "ባለሙያዎችን፣ ክህሎቶችን ፈልግ...";
  @override
  String get searchHintJobs => "ስራዎችን፣ ቁልፍ ቃላትን ፈልግ...";
  @override
  String get featuredPros => "⭐ ከፍተኛ ደረጃ የተሰጣቸው ባለሙያዎች";
  @override
  String get featuredJobs => "🚀 የቅርብ ጊዜ ክፍት ስራዎች";
  @override
  String get emptyStateProfessionals => "ምንም ባለሙያዎች አልተገኙም";
  @override
  String get emptyStateJobs => "መስፈርትዎን የሚያሟላ ስራ የለም";
  @override
  String get emptyStateDetails => "የፍለጋ ቃላትዎን ለማስተካከል ወይም ማጣሪያዎችን ለማጽዳት ይሞክሩ።";
  @override
  String get refreshButton => "አድስ";
  @override
  String get fabPostJob => "አዲስ ስራ ለጥፍ";
  @override
  String get fabMyProfile => "የእኔ መገለጫ";
  @override
  String get fabPostJobTooltip => "አዲስ የስራ ማስታወቂያ ፍጠር";
  @override
  String get fabMyProfileTooltip => "የሙያ መገለጫዎን ይመልከቱ ወይም ያርትዑ";
  @override
  String get filterOptionsTitle => "የማጣሪያ አማራጮች";
  @override
  String get filterCategory => "ምድብ / ሙያ";
  @override
  String get filterLocation => "ቦታ";
  @override
  String get filterJobStatus => "የስራ ሁኔታ";
  @override
  String get filterResetButton => "ዳግም አስጀምር";
  @override
  String get filterApplyButton => "ማጣሪያዎችን ተግብር";
  @override
  String get filtersResetSuccess => "ማጣሪያዎች ዳግም ተጀምረዋል";
  @override
  String workerCardJobsDone(int count) => "$count ስራዎች ተጠናቀዋል";
  @override
  String workerCardYearsExp(int years) => "$years ዓመት ልምድ";
  @override
  String get workerCardHire => "ቀጥር";
  @override
  String get jobCardView => "ዝርዝር እይ";
  @override
  String get jobStatusOpen => "ክፍት";
  @override
  String get jobStatusAssigned => "የተመደበ";
  @override
  String get jobStatusCompleted => "የተጠናቀቀ";
  @override
  String get paymentNoMethods => "ማስተካከልዎን አልተሰጠም።";
  @override
  String get jobStatusUnknown => "ያልታወቀ";
  @override
  String get jobDateN_A => "ቀን የለም";
  @override
  String get generalN_A => "የለም";
  @override
  String get jobUntitled => "ርዕስ አልባ ስራ";
  @override
  String get jobNoDescription => "መግለጫ አልተሰጠም።";
  @override
  String jobBudgetETB(String amount) => "$amount ብር";
  @override
  String get timeAgoJustNow => "አሁን";
  @override
  String timeAgoMinute(int minutes) => "ከ${minutes} ደቂቃ በፊት";
  @override
  String timeAgoHour(int hours) => "ከ${hours} ሰዓት በፊት";
  @override
  String timeAgoDay(int days) => "ከ${days} ቀን በፊት";
  @override
  String timeAgoWeek(int weeks) => "ከ${weeks} ሳምንት በፊት";
  @override
  String timeAgoMonth(int months) => "ከ${months} ወር በፊት";
  @override
  String timeAgoYear(int years) => "ከ${years} ዓመት በፊት";

  // WorkerDetail Screen
  @override
  String workerDetailAbout(String name) => "ስለ $name";
  @override
  String get workerDetailSkills => "ክህሎቶች";
  @override
  String get workerDetailAvailability => "ዝግጁነት";
  @override
  String workerDetailReviews(int count) => "ግምገማዎች ($count)";
  @override
  String get workerDetailLeaveReview => "ግምገማዎን ይተዉ";
  @override
  String get workerDetailHireNow => "አሁን ቀጥር";
  @override
  String get workerDetailWorking => "በስራ ላይ";
  @override
  String get workerDetailCall => "ደውል";
  @override
  String get workerDetailSubmitReview => "ግምገማ አስገባ";
  @override
  String get workerDetailShareProfileTooltip => "መገለጫ አጋራ";
  @override
  String get workerDetailAddFavoriteTooltip => "ወደ ተወዳጆች ጨምር";
  @override
  String get workerDetailRemoveFavoriteTooltip => "ከተወዳጆች አስወግድ";
  @override
  String get workerDetailAvailable => "ዝግጁ";
  @override
  String get workerDetailBooked => "ተይዟል";
  @override
  String get workerDetailSelectTime => "የጊዜ ሰሌዳ ምረጥ";
  @override
  String get workerDetailCancel => "ሰርዝ";
  @override
  String get workerDetailAnonymous => "ስም አልባ";
  @override
  String get workerDetailWriteReviewHint => "ተሞክሮዎን ያካፍሉ...";
  @override
  String workerDetailReviewLengthCounter(int currentLength, int maxLength) =>
      "$currentLength/$maxLength";
  @override
  String get workerDetailNoReviews => "እስካሁን ምንም ግምገማዎች የሉም።";
  @override
  String get workerDetailNoSkills => "ምንም ክህሎቶች አልተዘረዘሩም።";
  @override
  String get workerDetailNoAbout => "ምንም ዝርዝሮች አልተሰጡም።";
  @override
  String get workerDetailShowAll => "ሁሉንም አሳይ";
  @override
  String get workerDetailShowLess => "ትንሽ አሳይ";
  @override
  String get workermoneyempty => "አልተቀመጠም";

  // Notifications
  @override
  String get notificationTitle => "ማሳወቂያዎች";

  // Snackbars
  @override
  String get snackErrorLoading => "መረጃን በመጫን ላይ ስህተት።";
  @override
  String get snackErrorSubmitting => "ማስገባት አልተሳካም።";
  @override
  String get snackErrorGeneric => "ስህተት ተከስቷል። እባክዎ እንደገና ይሞክሩ።";
  @override
  String get snackSuccessReviewSubmitted => "ግምገማ በተሳካ ሁኔታ ገብቷል!";
  @override
  String get snackPleaseLogin => "እባክዎ ይህን ድርጊት ለመፈጸም ይግቡ።";
  @override
  String get snackFavoriteAdded => "ወደ ተወዳጆች ታክሏል!";
  @override
  String get paymentScreenTitle => "ክፍል አስቀም";
  @override
  String get paymentMethods => "ክፍሎች";
  @override
  String get paymentAddMethod => "አዲስ ክፍል ጨምር";
  @override
  String get snackFavoriteRemoved => "ከተወዳጆች ተወግዷል";
  @override
  String get snackPhoneNumberCopied => "ስልክ ቁጥር ተቀድቷል!";
  @override
  String get snackPhoneNumberNotAvailable => "ስልክ ቁጥር የለም።";
  @override
  String get snackErrorCheckFavorites => "ተወዳጆችን በማጣራት ላይ ስህተት።";
  @override
  String get snackErrorUpdateFavorites => "ተወዳጆችን ማዘመን አልተቻለም።";
  @override
  String get snackErrorContactInfo => "የመገኛ መረጃ በማምጣት ላይ ስህተት።";
  @override
  String get snackErrorLoadingProfile => "የእርስዎን መገለጫ በመጫን ላይ ስህተት።";
  @override
  String get snackReviewMissing => "እባክዎ ደረጃ እና አስተያየት ይስጡ።";
  @override
  String get snackWorkerNotFound => "የሰራተኛ መገለጫ አልተገኘም።";
  @override
  String get createJobSnackbarErrorWorker =>
      'የሰራተኛውን ዝርዝር በመጫን ላይ ስህተት ተፈጥሯል። እባክዎ እንደገና ይሞክሩ።';
  @override
  String get createJobSnackbarErrorUpload =>
      'አባሪዎችን በመጫን ላይ ስህተት ተፈጥሯል። እባክዎ እንደገና ይሞክሩ።';
  @override
  String get createJobSnackbarErrorUploadPartial => 'አንዳንድ አባሪዎች መጫን አልተሳካም።';
  @override
  String get createJobSnackbarErrorForm => 'እባክዎ በፎርሙ ላይ ያሉትን ስህተቶች ያስተካክሉ።';
  @override
  String get createJobSnackbarSuccess => 'ስራው በተሳካ ሁኔታ ተለጥፏል!';
  @override
  String get createJobSnackbarError => 'ስራውን መፍጠር አልተሳካም። እባክዎ እንደገና ይሞክሩ።';
  @override
  String createJobSnackbarFileSelected(int count) => '$count ፋይል(ሎች) ተመርጠዋል።';
  @override
  String get createJobSnackbarFileCancelled => 'ፋይል መምረጥ ተሰርዟል።';
  @override
  String get createJobSnackbarErrorPick =>
      'ፋይሎችን በመምረጥ ላይ ስህተት ተፈጥሯል። እባክዎ እንደገና ይሞክሩ።';
  @override
  String get snackErrorCameraNotAvailable => 'በዚህ መሣሪያ ላይ ካሜራ አይገኝም።';
  @override
  String get snackErrorCameraPermission =>
      'የካሜራ ፈቃድ ተከልክሏል። እባክዎ በቅንብሮች ውስጥ አንቁት።';
  @override
  String get snackErrorGalleryPermission =>
      'የጋለሪ ፈቃድ ተከልክሏል። እባክዎ በቅንብሮች ውስጥ አንቁት።';
  @override
  String get snackErrorReadFile => 'የፋይል መረጃ ማንበብ አልተቻለም።';
  @override
  String get snackSkippingUnknownType => 'ያልታወቀ የፋይል አይነት በመዝለል ላይ።';
  @override
  String get errorUserNotLoggedIn => "ተጠቃሚ አልገባም።";
  @override
  String get googleSignInCancelled => "በGoogle መግባት ተሰርዟል።";
  @override
  String get googleSignInAccountExists => "አካውንቱ በተለየ የመግቢያ መንገድ አስቀድሞ አለ።";

  // Dialogs
  @override
  String get phoneDialogTitle => "የመገኛ ስልክ ቁጥር";
  @override
  String get phoneDialogCopy => "ቁጥር ቅዳ";
  @override
  String get phoneDialogClose => "ዝጋ";

  // Job Detail Screen
  @override
  String get jobDetailAppBarTitle => "የስራ ዝርዝሮች";
  @override
  String get jobDetailLoading => "የስራ ዝርዝሮችን በመጫን ላይ...";
  @override
  String get jobDetailErrorLoading => "የስራ ዝርዝሮችን በመጫን ላይ ስህተት።";
  @override
  String get jobDetailStatusLabel => "ሁኔታ";
  @override
  String get jobDetailBudgetLabel => "በጀት";
  @override
  String get jobDetailLocationLabel => "ቦታ";
  @override
  String get jobDetailPostedDateLabel => "የተለጠፈበት ቀን";
  @override
  String get jobDetailScheduledDateLabel => "የታቀደለት ቀን";
  @override
  String get jobDetailDescriptionLabel => "መግለጫ";
  @override
  String get jobDetailAttachmentsLabel => "ተያያዥ ፋይሎች";
  @override
  String get jobDetailNoAttachments => "ምንም ተያያዥ ፋይሎች አልተሰጡም።";
  @override
  String get jobDetailAssignedWorkerLabel => "የተመደበ ባለሙያ";
  @override
  String get jobDetailNoWorkerAssigned => "እስካሁን ምንም ባለሙያ አልተመደበም።";
  @override
  String get jobDetailViewWorkerProfile => "መገለጫ ይመልከቱ";
  @override
  String get jobDetailApplicantsLabel => "አመልካቾች";
  @override
  String get jobDetailNoApplicantsYet => "እስካሁን ምንም ማመልከቻዎች አልተገኙም።";
  @override
  String get jobDetailViewApplicantsButton => "አመልካቾችን ይመልከቱ";
  @override
  String get jobDetailActionApply => "ለዚህ ስራ ያመልክቱ";
  @override
  String get jobDetailActionApplying => "በማመልከት ላይ...";
  @override
  String get jobDetailActionApplied => "ማመልከቻ ገብቷል";
  @override
  String get jobDetailActionCancelApplication => "ማመልከቻ ሰርዝ";
  @override
  String get jobDetailActionMarkComplete => "እንደተጠናቀቀ ምልክት አድርግ";
  @override
  String get jobDetailActionContactClient => "ደንበኛን ያግኙ";
  @override
  String get jobDetailActionPayNow => "ወደ ክፍያ ይቀጥሉ";
  @override
  String get jobDetailActionMessageWorker => "ባለሙያውን ያግኙ";
  @override
  String get jobDetailActionLeaveReview => "ግምገማ ይተዉ";
  @override
  String get jobDetailActionPostSimilar => "ተመሳሳይ ስራ ለጥፍ";
  @override
  String get jobDetailActionShare => "ይህንን ስራ አጋራ";
  @override
  String get jobDetailDeleteConfirmTitle => "ስራ ሰርዝ";
  @override
  String get jobDetailDeleteConfirmContent =>
      "ይህንን የስራ ማስታወቂያ እስከመጨረሻው መሰረዝ እንደሚፈልጉ እርግጠኛ ነዎት?";
  @override
  String get jobDetailDeleteConfirmKeep => "ስራውን አቆይ";
  @override
  String get jobDetailDeleteConfirmDelete => "ሰርዝ";
  @override
  String get jobDetailErrorAssigningWorker => "ሰራተኛን በመመደብ ላይ ስህተት።";
  @override
  String get jobDetailSuccessWorkerAssigned => "ሰራተኛ በተሳካ ሁኔታ ተመድቧል!";
  @override
  String get emailVerificationSentAmharic => 'ኢሜል ማረጋገጫ ተላከ።';

  @override
  String get emailVerifiedSuccessAmharic => 'ኢሜልዎ በተ成功 ማረጋገጫ ተሰርቷል!';

  @override
  String get emailNotVerifiedYetAmharic => 'ኢሜል እንደማይረጋገጥ ነው።';

  @override
  String get errorCheckingVerificationAmharic =>
      'ኢሜል ማረጋገጫ ማስፈንጠሪያ ስህተት ተከስቷል።';

  @override
  String get errorResendingEmailAmharic => 'ኢሜል ማስተናገድ ስህተት ተከስቷል።';

  @override
  String get verificationScreenTitleAmharic => 'ኢሜልዎን ማረጋገጫ አድርጉ';

  @override
  String get verificationScreenHeaderAmharic => 'እባኮትን እትም እንዲህ እትም ለመማረግ';

  @override
  String get verificationScreenInfoAmharic => 'ማረጋገጫ ማረጋገጪን እንዲመቻቹ።';

  @override
  String get checkingStatusButtonAmharic => 'ምርጠና እንደምታስርው ከሰከል';

  @override
  String get checkVerificationButtonAmharic => 'መስተናበራ መረጋጋጥ ጀምት ተአምᣨ';

  @override
  String get resendEmailButtonAmharic => 'ኢሜል ማስተናገድ';

  @override
  String get signOutButtonAmharic => 'አልተስማሙ እንበሰፈለቀ ወተጠዋት';
  @override
  String get jobDetailErrorApplying => "ማመልከቻን በማስገባት ላይ ስህተት።";
  @override
  String get jobDetailSuccessApplied => "ማመልከቻ በተሳካ ሁኔታ ገብቷል!";
  @override
  String get jobDetailErrorDeleting => "ስራን በመሰረዝ ላይ ስህተት።";
  @override
  String get jobDetailSuccessDeleted => "ስራ በተሳካ ሁኔታ ተሰርዟል።";
  @override
  String get jobDetailErrorMarkingComplete =>
      "ስራን እንደተጠናቀቀ ምልክት በማድረግ ላይ ስህተት።";
  @override
  String get jobDetailSuccessMarkedComplete => "ስራ እንደተጠናቀቀ ምልክት ተደርጓል!";
  @override
  String get jobDetailFeatureComingSoon => "ይህ አገልግሎት በቅርቡ ይመጣል!";
  @override
  String get jobDetailApplicantHireButton => "ቀጥር";
  @override
  String get clientNameLabel => "ደንበኛ";

  // Create Job Screen
  @override
  String get createJobCategoryLabel => 'የስራ አይነት (ምድብ)';
  @override
  String get createJobCategoryHint => 'የስራውን አይነት ይምረጡ';
  @override
  String get createJobErrorCategory => 'እባክዎ የስራውን አይነት ይምረጡ።';
  @override
  String get createJobSkillLabel => 'የሚፈለግ ክህሎት / ተግባር';
  @override
  String get createJobSkillHint => 'የሚፈለገውን ክህሎት ይምረጡ';
  @override
  String get createJobErrorSkill => 'እባክዎ የሚፈለገውን ክህሎት/ተግባር ይምረጡ።';
  @override
  String get attachOptionGallery => 'ከጋለሪ ይምረጡ';
  @override
  String get attachOptionCamera => 'ፎቶ አንሳ';
  @override
  String get attachOptionFile => 'ፋይል ምረጥ';
  @override
  String get attachOptionCancel => 'ይቅር';
  @override
  String get attachTitle => 'አባሪ ጨምር';
  @override
  String get createJobCalendarTitle => 'የስራ ቀን ይምረጡ';
  @override
  String get createJobCalendarCancel => 'ይቅር';
  @override
  String get createJobAppBarTitle => 'አዲስ ስራ ይፍጠሩ';
  @override
  String get createJobSelectedWorkerSectionTitle => 'የተመረጠ ሰራተኛ';
  @override
  String get createJobDetailsSectionTitle => 'የስራ ዝርዝሮች';
  @override
  String get createJobOptionalSectionTitle => 'ተጨማሪ ዝርዝሮች (አማራጭ)';
  @override
  String get createJobTitleLabel => 'የስራ ርዕስ';
  @override
  String get createJobTitleHint => 'ለምሳሌ፦ የቧንቧ ውሃ ጠብታ ማስተካከል';
  @override
  String get createJobTitleError => 'እባክዎ የስራ ርዕስ ያስገቡ።';
  @override
  String get createJobDescLabel => 'መግለጫ';
  @override
  String get createJobDescHint => 'ስለ ስራው ዝርዝር መረጃ ያቅርቡ... (ቢያንስ 20 ቁምፊዎች)';
  @override
  String get createJobDescErrorEmpty => 'እባክዎ መግለጫ ያስገቡ።';
  @override
  String get createJobDescErrorShort => 'መግለጫው ቢያንስ 20 ቁምፊዎች ሊኖረው ይገባል።';
  @override
  String get createJobBudgetLabel => 'በጀት (ብር)';
  @override
  String get createJobBudgetHint => 'ለምሳሌ፦ 500';
  @override
  String get createJobBudgetErrorEmpty => 'እባክዎ የበጀት መጠን ያስገቡ።';
  @override
  String get createJobBudgetErrorNaN => 'እባክዎ ትክክለኛ ቁጥር ለበጀት ያስገቡ።';
  @override
  String get createJobBudgetErrorPositive => 'በጀቱ ከዜሮ በላይ መሆን አለበት።';
  @override
  String get createJobLocationLabel => 'ቦታ';
  @override
  String get createJobLocationHint => 'ለምሳሌ፦ ቦሌ, አዲስ አበባ';
  @override
  String get createJobLocationError => 'እባክዎ የስራውን ቦታ ያስገቡ።';
  @override
  String get createJobScheduleLabelOptional => 'የጊዜ ሰሌዳ ቀን (አማራጭ)';
  @override
  String createJobScheduleLabelSet(String date) => 'የተያዘለት ቀን፦ $date';
  @override
  String get createJobScheduleSub => 'የሚመርጡትን ቀን ለመምረጥ ይንኩ';
  @override
  String get createJobAttachmentsLabelOptional => 'አባሪዎች (አማራጭ)';
  @override
  String get createJobAttachmentsSubAdd => 'ፎቶዎችን ወይም ሰነዶችን ለማከል ይንኩ';
  @override
  String createJobAttachmentsSubCount(int count) => '$count ፋይል(ሎች) ተያይዘዋል።';
  @override
  String get createJobUrgentLabel => 'እንደ አስቸኳይ ምልክት ያድርጉ';
  @override
  String get createJobUrgentSub => 'አስቸኳይ ስራዎች ፈጣን ምላሽ ሊያገኙ ይችላሉ';
  @override
  String get createJobButtonPosting => 'እየለጠፈ ነው...';
  @override
  String get createJobButtonPost => 'ስራውን ለጥፍ';
  @override
  String get registerErrorProfessionRequired => "እባክዎ ሙያዎን ያስገቡ።";
  @override
  String get errorPasswordShort => "የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት።";

  // Job Dashboard Screen
  @override
  String get dashboardTitleDefault => "ዳሽቦርድ";
  @override
  String get dashboardTitleWorker => "የእኔ የስራ ዳሽቦርድ";
  @override
  String get dashboardTitleClient => "የእኔ የስራዎች ዳሽቦርድ";
  @override
  String get tabWorkerAssigned => "ለኔ የተመደቡ";
  @override
  String get tabWorkerApplied => "የእኔ ማመልከቻዎች";
  @override
  String get tabWorkerActive => "በሂደት/ተጠናቋል";
  @override
  String get tabClientPosted => "የለጠፍኳቸው";
  @override
  String get tabClientApplications => "አመልካቾች";
  @override
  String get tabClientRequests => "ጥያቄዎቼ";
  @override
  String get filterAll => "ሁሉም";
  @override
  String get filterOpen => "ክፍት";
  @override
  String get filterPending => "በመጠባበቅ ላይ";
  @override
  String get filterAssigned => "የተመደበ";
  @override
  String get filterAccepted => "ተቀባይነት ያለው";
  @override
  String get filterInProgress => "በሂደት ላይ";
  @override
  String get filterStartedWorking => "በስራ ላይ";
  @override
  String get filterCompleted => "የተጠናቀቀ";
  @override
  String get filterCancelled => "የተሰረዘ";
  @override
  String get filterRejected => "ውድቅ የተደረገ";
  @override
  String get filterClosed => "የተዘጋ";
  @override
  String get emptyStateWorkerAssigned => "እስካሁን የተመደበልዎት ስራ የለም";
  @override
  String get emptyStateWorkerApplied => "እስካሁን ላוםንም ስራ አላመለከቱም";
  @override
  String get emptyStateWorkerActive => "በሂደት ላይ ያለ ወይም የተጠናቀቀ ስራ የለም";
  @override
  String get emptyStateClientPosted => "እስካሁን ምንም ስራ አልለጠፉም";
  @override
  String get emptyStateClientApplications => "እስካሁን ምንም ማመልከቻ አልደረሰዎትም";
  @override
  String get emptyStateClientRequests => "በቀጥታ የጠየቁት ስራ የለም";
  @override
  String get emptyStateJobsFilteredTitle => "ማጣሪያውን የሚያሟላ ስራ የለም";
  @override
  String get emptyStateJobsFilteredSubtitle =>
      "ከላይ ያለውን የሁኔታ ማጣሪያ ለማስተካከል ይሞክሩ።";
  @override
  String get emptyStateGeneralSubtitle => "በኋላ ተመልሰው ይሞክሩ ወይም ያድሱ።";
  @override
  String get noApplicantsSubtitle => "ሰራተኞች ሲያመለክቱ እዚህ ይታያሉ።";
  @override
  String get buttonAccept => "ተቀበል";
  @override
  String get buttonStartWork => "ስራ ጀምር";
  @override
  String get buttonComplete => "አጠናቅ";
  @override
  String get buttonViewApplicants => "አመልካቾችን እይ";
  @override
  String get buttonChatClient => "ደንበኛ አውራ";
  @override
  String get buttonChatWorker => "ሰራተኛ አውራ";
  @override
  String get buttonPayWorker => "ለሰራተኛ ክፈል";
  @override
  String get buttonCancelJob => "ስራ ሰርዝ";
  @override
  String get viewProfileButton => "መገለጫ እይ";
  @override
  String get viewAllApplicantsButton => "ሁሉንም እይ";
  @override
  String get buttonChat => "አውራ";
  @override
  String get jobAcceptedSuccess => "ስራው በተሳካ ሁኔታ ተቀባይነት አግኝቷል!";
  @override
  String get jobAcceptedError => "ስራውን መቀበል አልተቻለም።";
  @override
  String get jobStartedSuccess => "ስራ ተጀምሯል!";
  @override
  String get jobStartedError => "ሁኔታውን ወደ 'ተጀምሯል' ማዘመን አልተቻለም።";
  @override
  String get applicantLoadError => "አመልካቾችን በመጫን ላይ ስህተት።";
  @override
  String applicantsForJob(String jobTitle) => "ለ '$jobTitle' አመልካቾች";
  @override
  String get applicantNotFound => "አመልካች አልተገኘም";
  @override
  String get skillsLabel => "ክህሎቶች:";
  @override
  String get aboutLabel => "ስለ:";
  @override
  String get priceRangeLabel => "የዋጋ ክልል";
  @override
  String get experienceLabel => "ልምድ";
  @override
  String get phoneLabel => "ስልክ";
  @override
  String get timelinePending => "በመጠባበቅ ላይ";
  @override
  String get timelineInProgress => "በሂደት ላይ";
  @override
  String get timelineCompleted => "ተጠናቋል";

  // --- Login Screen ---
  @override
  String get loginTitle => "እንኳን ደህና መጡ!";
  @override
  String get loginWelcome => "ለመቀጠል ይግቡ";
  @override
  String get loginEmailLabel => "ኢሜል";
  @override
  String get loginEmailHint => "ኢሜልዎን ያስገቡ";
  @override
  String get loginPasswordLabel => "የይለፍ ቃል";
  @override
  String get loginPasswordHint => "የይለፍ ቃልዎን ያስገቡ";
  @override
  String get loginRememberMe => "አስታውሰኝ";
  @override
  String get loginForgotPassword => "የይለፍ ቃል ረስተዋል?";
  @override
  String get loginButton => "ግባ";
  @override
  String get loginNoAccount => "አካውንት የለዎትም? ";
  @override
  String get loginSignUpLink => "ይመዝገቡ";
  @override
  String get loginErrorUserNotFound => "ለዚህ ኢሜል ምንም ተጠቃሚ አልተገኘም።";
  @override
  String get loginErrorWrongPassword => "የተሳሳተ የይለፍ ቃል አስገብተዋል።";
  @override
  String get loginErrorInvalidEmail => "የኢሜል አድራሻው ቅርጸት ልክ አይደለም።";
  @override
  String get loginErrorUserDisabled => "ይህ የተጠቃሚ መለያ ታግዷል።";
  @override
  String get loginErrorTooManyRequests =>
      "በጣም ብዙ የመግባት ሙከራዎች። እባክዎ ቆይተው እንደገና ይሞክሩ።";
  @override
  String get loginErrorUnknown => "መግባት አልተሳካም። እባክዎ መረጃዎን ያረጋግጡ።";
  @override
  String get loginWithGoogle => "በGoogle ይግቡ";
  @override
  String get loginErrorGoogleSignIn => "በGoogle መግባት አልተሳካም። እባክዎ እንደገና ይሞክሩ።";

  // --- Register Screen ---
  @override
  String get registerTitle => "አካውንት ፍጠር";
  @override
  String get registerSubtitle => "የደንበኞች እና ባለሙያዎች ማህበረሰባችንን ይቀላቀሉ";
  @override
  String get registerUserTypePrompt => "እኔ:";
  @override
  String get registerUserTypeClient => "ደንበኛ (ቀጣሪ)";
  @override
  String get registerUserTypeWorker => "ባለሙያ (ሰራተኛ)";
  @override
  String get registerProfessionLabel => "የእርስዎ ሙያ";
  @override
  String get registerProfessionHint => "ለምሳሌ፦ የቧንቧ ሰራተኛ፣ ኤሌክትሪሻን";
  @override
  String get registerFullNameLabel => "ሙሉ ስም";
  @override
  String get registerFullNameHint => "ሙሉ ስምዎን ያስገቡ";
  @override
  String get registerPhoneLabel => "ስልክ ቁጥር";
  @override
  String get registerPhoneHint => "ስልክ ቁጥርዎን ያስገቡ";
  @override
  String get registerConfirmPasswordLabel => "የይለፍ ቃል አረጋግጥ";
  @override
  String get registerConfirmPasswordHint => "የይለፍ ቃልዎን እንደገና ያስገቡ";
  @override
  String get registerButton => "አካውንት ፍጠር";
  @override
  String get registerHaveAccount => "አካውንት አለዎት? ";
  @override
  String get registerSignInLink => "ይግቡ";
  @override
  String get registerErrorPasswordMismatch => "የይለፍ ቃሎች አይዛመዱም።";
  @override
  String get registerErrorWeakPassword => "የቀረበው የይለፍ ቃል በጣም ደካማ ነው።";
  @override
  String get registerErrorEmailInUse => "ለዚህ ኢሜል አካውንት አስቀድሞ አለ።";
  @override
  String get registerErrorInvalidEmailRegister => "የኢሜል አድራሻው ቅርጸት ልክ አይደለም።";
  @override
  String get registerErrorUnknown => "ምዝገባ አልተሳካም። እባክዎ እንደገና ይሞክሩ።";
  @override
  String get registerWithGoogle => "በGoogle ይመዝገቡ";
  @override
  String get registerSuccess => "ምዝገባው ተሳክቷል!";
  @override
  String get registerNavigateToSetup => "ወደ ባለሙያ ማዋቀሪያ በመሄድ ላይ...";
  @override
  String get registerNavigateToHome => "ወደ መነሻ በመሄድ ላይ...";

  // --- Forgot Password Screen ---
  @override
  String get forgotPasswordTitle => "የይለፍ ቃል ዳግም አስጀምር";
  @override
  String get forgotPasswordInstructions =>
      "የኢሜል አድራሻዎን ከታች ያስገቡ እና የይለፍ ቃልዎን ዳግም ለማስጀመር ሊንክ እንልክልዎታለን።";
  @override
  String get forgotPasswordButton => "የዳግም ማስጀመሪያ ሊንክ ላክ";
  @override
  String get forgotPasswordSuccess =>
      "የይለፍ ቃል ዳግም ማስጀመሪያ ኢሜል ተልኳል! እባክዎ የገቢ መልዕክት ሳጥንዎን ያረጋግጡ።";
  @override
  String get forgotPasswordError =>
      "የዳግም ማስጀመሪያ ኢሜል በመላክ ላይ ስህተት። እባክዎ አድራሻውን ያረጋግጡና እንደገና ይሞክሩ።";

  // --- Helper Method Implementations ---
  @override
  String getStatusName(String key) {
    switch (key.toLowerCase()) {
      case 'open':
        return filterOpen;
      case 'pending':
        return filterPending;
      case 'assigned':
        return filterAssigned;
      case 'accepted':
        return filterAccepted;
      case 'in_progress':
        return filterInProgress;
      case 'started working':
        return filterStartedWorking;
      case 'completed':
        return filterCompleted;
      case 'cancelled':
        return filterCancelled;
      case 'rejected':
        return filterRejected;
      case 'closed':
        return filterClosed;
      default:
        return key.toUpperCase();
    }
  }

  @override
  IconData? getFilterIcon(String key) {
    switch (key.toLowerCase()) {
      case 'all':
        return Icons.list_alt_rounded;
      case 'open':
        return Icons.lock_open_rounded;
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'assigned':
        return Icons.assignment_ind_outlined;
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'in_progress':
        return Icons.construction_rounded;
      case 'started working':
        return Icons.play_circle_outline_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'rejected':
        return Icons.thumb_down_alt_outlined;
      case 'closed':
        return Icons.lock_outline_rounded;
      default:
        return null;
    }
  }

  @override
  String getFilterName(String key) => getStatusName(key);
  @override
  IconData? getEmptyStateIcon(String key) {
    if (key == emptyStateWorkerAssigned) return Icons.assignment_late_outlined;
    if (key == emptyStateWorkerApplied)
      return Icons.playlist_add_check_circle_outlined;
    if (key == emptyStateWorkerActive) return Icons.construction_rounded;
    if (key == emptyStateClientPosted) return Icons.post_add_rounded;
    if (key == emptyStateClientApplications) return Icons.people_alt_outlined;
    if (key == emptyStateClientRequests) return Icons.request_page_outlined;
    return Icons.search_off_rounded;
  }

  @override
  String yearsExperience(int years) => "$years ዓመት ልምድ";
  @override
  String applicantCount(int count) => "$count አመልካች${count == 1 ? '' : 'ዎች'}";
  @override
  String jobsCompleted(int count) => "$count ስራዎች ተጠናቀዋል";
  @override
  String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60) return timeAgoJustNow;
    if (difference.inMinutes < 60) return timeAgoMinute(difference.inMinutes);
    if (difference.inHours < 24) return timeAgoHour(difference.inHours);
    if (difference.inDays < 7) return timeAgoDay(difference.inDays);
    if (difference.inDays < 30)
      return timeAgoWeek((difference.inDays / 7).floor());
    if (difference.inDays < 365)
      return timeAgoMonth((difference.inDays / 30).floor());
    return timeAgoYear((difference.inDays / 365).floor());
  }

  @override
  String errorFieldRequired(String fieldName) => "እባክዎ $fieldName ያስገቡ።";
  @override
  String getUserTypeDisplayName(String key) {
    switch (key) {
      case 'registerUserTypeClient':
        return registerUserTypeClient;
      case 'registerUserTypeWorker':
        return registerUserTypeWorker;
      default:
        return key;
    }
  }
}

// ===========================================================
//                 Oromo Implementation (Placeholder)
// ===========================================================
// TODO: Create AppStringsOm class implementing AppStrings with Oromo translations

// ===========================================================
//           Localization Delegate and Helper
// ===========================================================
class AppLocalizations {
  final Locale locale;
  final AppStrings strings;

  AppLocalizations(this.locale, this.strings);

  static AppStrings? of(BuildContext context) {
    try {
      // Use Provider for locale state management
      final provider = Provider.of<LocaleProvider>(context, listen: false);
      return getStrings(provider.locale);
    } catch (e) {
      debugPrint(
          "Error getting AppLocalizations via Provider: $e. Using default (English).");
      return _localizedValues['en']!; // Fallback
    }
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, AppStrings> _localizedValues = {
    'en': AppStringsEn(),
    'am': AppStringsAm(),
    // 'om': AppStringsOm(), // Uncomment and implement when Oromo is added
  };

  static AppStrings getStrings(Locale locale) {
    return _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
  }

  static Iterable<Locale> get supportedLocales =>
      _localizedValues.keys.map((langCode) => Locale(langCode));
}

// Delegate for loading strings
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  // Update with all supported language codes
  static const _supportedLanguageCodes = ['en', 'am']; // Add 'om' when ready

  @override
  bool isSupported(Locale locale) =>
      _supportedLanguageCodes.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppStrings strings = AppLocalizations.getStrings(locale);
    return AppLocalizations(locale, strings);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;

  // Expose supported locales for MaterialApp
  Iterable<Locale> get supportedLocales =>
      _supportedLanguageCodes.map((langCode) => Locale(langCode));
}
