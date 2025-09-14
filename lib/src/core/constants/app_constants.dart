class AppConstants {
  // App Information
  static const appName = 'Check-In Tracker';

  // Button Texts
  static const clear = 'Clear';
  static const findRoute = 'Find Route';
  static const cancel = 'Cancel';
  static const remove = 'Remove';
  static const openSettings = 'Open Settings';
  static const grantPermission = 'Grant Permission';

  // Dialog Titles and Content
  static const locationPermissionRequired = 'Location Permission Required';
  static const locationPermissionMessage =
      'This app needs location permission to show your current location on the'
      ' map and provide accurate route information.\n\n'
      'Please go to Settings > Apps > [App Name] > Permissions and enable '
      'Location access.';

  // Snackbar Messages
  static const locationPermissionGranted =
      'Location permission granted! Map updated with your location.';
  static const locationPermissionGrantedTemporarily =
      'Location permission granted for this session.';
  static const locationPermissionNotGranted =
      'Location permission not granted. Please enable it in settings.';
  static const enableLocationServices =
      'Please enable Location Services in your device settings to use this app.';

  // Route Quality Labels
  static const routeQualityExcellent = 'Excellent';
  static const routeQualityGood = 'Good';
  static const routeQualityFair = 'Fair';
  static const routeQualityPoor = 'Poor';

  // Units
  static const kilometers = 'km';
  static const minutes = 'min';
  static const hours = 'h';
  static const seconds = 's';
  static const na = 'N/A';

  // Error Messages
  static const emptyApiKeyError =
      'Empty API key received from native configuration';
  static const unexpectedApiKeyError =
      'Unexpected error getting API key: {error}';

  // Map Constants
  static const defaultLatitude = 23.8041;
  static const defaultLongitude = 90.4152;
  static const defaultZoom = 12.0;
  static const currentLocationZoom = 15.0;
  static const routePolylineWidth = 5;
  static const routeBoundsPadding = 200.0;
  static const maxMarkers = 2;

  // Map Screen
  static const checkinMapTitle = 'Check-in Map';
  static const signOut = 'Sign Out';
  static const signOutValue = 'signout';
  static const createEventFab = 'create_event_fab';
  static const myLocationFab = 'my_location_fab';
  static const eventsListFab = 'events_list_fab';
  static const activeCheckins = 'Active';
  static const radiusLabel = 'Radius';
  static const locationLabel = 'Location';
  static const currentlyCheckedIn = 'You are currently checked in';
  static const checkOut = 'Checkout';
  static const checkIn = 'Check In';
  static const navigatedToEventLocation = 'Navigated to event location';
  static const autoLogoutMessage =
      'You have been automatically logged out because you moved out of the check-in radius.';

  // Location and Permission Messages
  static const locationNotAvailable = 'Location not available';
  static const checkinFailed = 'Check-in failed';
  static const checkoutFailed = 'Check-out failed';
  static const locationPermissionRequiredForEvents =
      'Location permission is required to create events';
  static const locationServiceDisabled =
      'Location service is disabled. Please enable GPS in your device settings.';
  static const unableToGetLocation =
      'Unable to get your location. Please check your GPS settings and ensure you are outdoors or near a window.';
  static const failedToGetLocation = 'Failed to get location';

  // Auth Screen Messages
  static const signUpSuccessful = 'Sign Up Successful!';
  static const accountCreatedMessage =
      'Your account has been created successfully.';
  static const pleaseSignInMessage =
      'Please sign in to continue using the app.';
  static const signIn = 'Sign In';
  static const signUpFailed = 'Sign up failed';
  static const loginFailed = 'Login failed';
  static const alreadyHaveAccount = 'Already have an account? Sign in';
  static const dontHaveAccount = "Don't have an account? Sign up";

  // Event Details Dialog
  static const eventDetails = 'Event Details';
  static const createdBy = 'Created by';
  static const createdAt = 'Created at';
  static const activeCheckinsTitle = 'Active Check-ins';
  static const people = 'people';
  static const checkedInUsers = 'Checked-in Users';
  static const currentlyCheckedInToEvent =
      'You are currently checked in to this event';
  static const notCheckedInToEvent = 'You are not checked in to this event';
  static const close = 'Close';
  static const deleteEvent = 'Delete';
  static const successfullyCheckedIn = 'Successfully checked in!';
  static const successfullyCheckedOut = 'Successfully checked out!';
  static const eventDeletedSuccessfully = 'Event deleted successfully!';
  static const deleteFailed = 'Delete failed';

  // Check-in Point Dialog
  static const createCheckinPoint = 'Check-in Event';
  static const editCheckinPoint = 'Edit Check-in Point';
  static const eventName = 'Event Name';
  static const createdByLabel = 'Your Name';
  static const radiusMeters = 'Radius (Meters)';
  static const create = 'Create';
  static const update = 'Update';

  // Events List Dialog
  static const allEvents = 'All Events';
  static const noEventsCreated = 'No events created yet';
  static const createFirstEvent = 'Create your first event to get started!';
  static const failedToLoadEvents = 'Failed to load events';
  static const unknownError = 'Unknown error occurred';
  static const view = 'View';

  // Location Permission Blocker
  static const locationPermissionRequiredTitle = 'Location Permission Required';
  static const locationPermissionRequiredMessage =
      'This app requires location permission to function properly. Please grant location access to continue.';
  static const checkingLocationPermissionMessage =
      'Checking location permission...';

  // Form Validation Messages
  static const pleaseEnterName = 'Please enter your name';
  static const nameMinLength = 'Name must be at least 2 characters';
  static const pleaseEnterEmail = 'Please enter your email';
  static const pleaseEnterValidEmail = 'Please enter a valid email';
  static const pleaseEnterPassword = 'Please enter your password';
  static const passwordMinLength = 'Password must be at least 6 characters';
  static const pleaseConfirmPassword = 'Please confirm your password';
  static const passwordsDoNotMatch = 'Passwords do not match';
  static const pleaseEnterEventName = 'Please enter event name';
  static const eventNameMinLength = 'Event name must be at least 3 characters';
  static const pleaseEnterCreatorName = 'Please enter your name';
  static const creatorNameMinLength = 'Your name must be at least 3 characters';
  static const pleaseEnterRadius = 'Please enter radius';
  static const pleaseEnterValidRadius = 'Please enter a valid radius';
  static const radiusMinValue = 'Radius must be at least 10 meters';
  static const radiusMaxValue = 'Radius must be less than 1000 meters';

  // Time Formatting
  static const justNow = 'Just now';
  static const daysAgo = 'd ago';
  static const hoursAgo = 'h ago';
  static const minutesAgo = 'm ago';

  // Units
  static const meters = 'm';
  static const monospaceFont = 'monospace';

  // Tips and Help Messages
  static const tips = 'Tips:';
  static const moveCloser = '• Move closer to the event location';
  static const checkCorrectEvent =
      '• Check if you have the correct event selected';
  static const ensureLocationServices =
      '• Ensure your location services are enabled';

  // Auth Screen Labels
  static const emailLabel = 'Email';
  static const passwordLabel = 'Password';
  static const fullNameLabel = 'Full Name';
  static const confirmPasswordLabel = 'Confirm Password';
  static const signInToCreate = 'Sign in to create and manage check-in points';
  static const signUpToCreate = 'Sign Up to create and manage check-in points';
  static const createAccount = 'Create Account';

  // Dialog Labels
  static const ok = 'OK';
  static const createEventAtCurrentLocation =
      'Create Event at Current Location';
  static const yesCreateEvent = 'Yes, Create Event';
  static const exitApp = 'Exit App';
  static const createNewEvent = 'Create New Event';
  static const viewEvent = 'View Event';

  // Create Event Dialog
  static const createEventConfirmation =
      'Do you want to create a check-in event at your current location?';
  static const currentLocationLabel = 'Current Location:';
  static const latitudeLabel = 'Latitude:';
  static const longitudeLabel = 'Longitude:';
  static const eventCreationSteps =
      'You will be able to set the event name and radius in the next step.';

  // Location Permission Settings Dialog
  static const locationPermissionRequiredDescription =
      'This app requires location permission to function properly.';
  static const locationPermissionPermanentlyDenied =
      'Location permission has been permanently denied. Please enable it manually in your device settings.';
  static const stepsToEnableLocation = 'Steps to enable location permission:';
  static const step1OpenSettings = '1. Tap "Open Settings" below';
  static const step2FindLocation = '2. Find "Location" or "Permissions"';
  static const step3EnablePermission =
      '3. Enable location permission for this app';
  static const step4ReturnToApp = '4. Return to this app and try again';

  // User Display
  static const unknownUser = 'Unknown';

  // Check-in Area Messages
  static const withinCheckinArea = 'You are within the check-in area!';
  static const outsideCheckinArea = 'You are outside the check-in area.';

  // Map Click Dialog
  static const mapLocation = 'Map Location';
  static const nearbyEvent = 'Nearby Event:';
  static const whatWouldYouLikeToDo = 'What would you like to do?';
  static const noEventsFoundAtLocation = 'No events found at this location.';
  static const wouldYouLikeToCreateNewEvent =
      'Would you like to create a new event?';
  static const createEvent = 'Create';

  // Error Messages
  static const tooFarMessage = 'too far';
  static const unexpectedErrorOccurred = 'An unexpected error occurred';
  static const deleteConfirmationMessage = 'Are you sure you want to delete';
  static const deleteConfirmationDetails =
      'This action cannot be undone and will remove all check-ins for this event.';

  // User Display
  static const userPrefix = 'User';

  // Logout Confirmation
  static const logoutConfirmationTitle = 'Logout';
  static const logoutConfirmationMessage = 'Are you sure you want to logout?';
  static const yes = 'Yes';
  static const no = 'No';
}
