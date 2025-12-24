import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'GlucoTrack'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get hello;

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get totalRecords;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @lowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get lowest;

  /// No description provided for @highest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highest;

  /// No description provided for @yourMission.
  ///
  /// In en, this message translates to:
  /// **'Your Mission'**
  String get yourMission;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'view all'**
  String get viewAll;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout Confirmation'**
  String get logoutConfirm;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(int age);

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @daysStreak.
  ///
  /// In en, this message translates to:
  /// **'Days Streak'**
  String get daysStreak;

  /// No description provided for @missionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Missions Completed'**
  String get missionsCompleted;

  /// No description provided for @yourNextMission.
  ///
  /// In en, this message translates to:
  /// **'Your Next Mission'**
  String get yourNextMission;

  /// No description provided for @noMissionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No missions available'**
  String get noMissionsAvailable;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @mgDl.
  ///
  /// In en, this message translates to:
  /// **'mg/dL'**
  String get mgDl;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @beforeMeal.
  ///
  /// In en, this message translates to:
  /// **'Before Meal'**
  String get beforeMeal;

  /// No description provided for @afterMeal.
  ///
  /// In en, this message translates to:
  /// **'After Meal'**
  String get afterMeal;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResult;

  /// No description provided for @shareResultMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to share your current blood glucose test results?'**
  String get shareResultMessage;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesShare.
  ///
  /// In en, this message translates to:
  /// **'Yes, Share'**
  String get yesShare;

  /// No description provided for @selectDateTimeFirst.
  ///
  /// In en, this message translates to:
  /// **'Select date and time first.'**
  String get selectDateTimeFirst;

  /// No description provided for @glucoseDataSaved.
  ///
  /// In en, this message translates to:
  /// **'Glucose data saved successfully.'**
  String get glucoseDataSaved;

  /// No description provided for @failedSaveDatabase.
  ///
  /// In en, this message translates to:
  /// **'Failed to save data to database.'**
  String get failedSaveDatabase;

  /// No description provided for @failedSaveData.
  ///
  /// In en, this message translates to:
  /// **'Failed to save data: {error}'**
  String failedSaveData(String error);

  /// No description provided for @glucoseRecord.
  ///
  /// In en, this message translates to:
  /// **'Glucose Record'**
  String get glucoseRecord;

  /// No description provided for @glucoseLevelMgDl.
  ///
  /// In en, this message translates to:
  /// **'Blood Glucose Level (mg/dL)'**
  String get glucoseLevelMgDl;

  /// No description provided for @glucoseLevelRequired.
  ///
  /// In en, this message translates to:
  /// **'Glucose level cannot be empty'**
  String get glucoseLevelRequired;

  /// No description provided for @validNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validNumberRequired;

  /// No description provided for @iotDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'IoT data loaded successfully'**
  String get iotDataLoaded;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @iotDeviceData.
  ///
  /// In en, this message translates to:
  /// **'IoT Device Data'**
  String get iotDeviceData;

  /// No description provided for @measurementCondition.
  ///
  /// In en, this message translates to:
  /// **'Measurement Condition'**
  String get measurementCondition;

  /// No description provided for @useCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Use Current Time'**
  String get useCurrentTime;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateTime;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time: '**
  String get dateTime;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @whatsUp.
  ///
  /// In en, this message translates to:
  /// **'What\'s up, {name}!'**
  String whatsUp(String name);

  /// No description provided for @haveAnythingToShare.
  ///
  /// In en, this message translates to:
  /// **'Have anything to share?'**
  String get haveAnythingToShare;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search posts, articles, or users...'**
  String get searchHint;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get forYou;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @failedTriggerEsp32.
  ///
  /// In en, this message translates to:
  /// **'Failed to send trigger to ESP32'**
  String get failedTriggerEsp32;

  /// No description provided for @timeoutEsp32.
  ///
  /// In en, this message translates to:
  /// **'Timeout: ESP32 not responding'**
  String get timeoutEsp32;

  /// No description provided for @measureAgain.
  ///
  /// In en, this message translates to:
  /// **'Measure Again'**
  String get measureAgain;

  /// No description provided for @startMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Start Measurement'**
  String get startMeasurement;

  /// No description provided for @checkGlucoseNow.
  ///
  /// In en, this message translates to:
  /// **'Check your glucose now!'**
  String get checkGlucoseNow;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @measurementProcess.
  ///
  /// In en, this message translates to:
  /// **'Measurement Process'**
  String get measurementProcess;

  /// No description provided for @measurementResult.
  ///
  /// In en, this message translates to:
  /// **'Measurement Result'**
  String get measurementResult;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence: '**
  String get confidence;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @measurementFailed.
  ///
  /// In en, this message translates to:
  /// **'Measurement Failed'**
  String get measurementFailed;

  /// No description provided for @articleDetail.
  ///
  /// In en, this message translates to:
  /// **'Article\'s Detail'**
  String get articleDetail;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @socialMediaFeed.
  ///
  /// In en, this message translates to:
  /// **'Social Media Feed'**
  String get socialMediaFeed;

  /// No description provided for @iotConnection.
  ///
  /// In en, this message translates to:
  /// **'IoT Connection'**
  String get iotConnection;

  /// No description provided for @testingSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'testing social media'**
  String get testingSocialMedia;

  /// No description provided for @writeSomethingFirst.
  ///
  /// In en, this message translates to:
  /// **'Write something first'**
  String get writeSomethingFirst;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'Posted!'**
  String get posted;

  /// No description provided for @failedToPost.
  ///
  /// In en, this message translates to:
  /// **'Failed to post: {error}'**
  String failedToPost(String error);

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @failedToLoadFeed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feed: {error}'**
  String failedToLoadFeed(String error);

  /// No description provided for @writeSomethingOrAddImage.
  ///
  /// In en, this message translates to:
  /// **'Write something or add an image'**
  String get writeSomethingOrAddImage;

  /// No description provided for @failedToCreateImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to create image: {error}'**
  String failedToCreateImage(String error);

  /// No description provided for @failedToShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share: {error}'**
  String failedToShare(String error);

  /// No description provided for @congratulationsPoints.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You earned {points} points'**
  String congratulationsPoints(int points);

  /// No description provided for @failedToClaimPoints.
  ///
  /// In en, this message translates to:
  /// **'Failed to claim points'**
  String get failedToClaimPoints;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @article1Title.
  ///
  /// In en, this message translates to:
  /// **'Exercise: The Medicine You Can\'t Skip.'**
  String get article1Title;

  /// No description provided for @article1Preview.
  ///
  /// In en, this message translates to:
  /// **'Stay active to boost both body and brain. Skipping workouts means missing your health.'**
  String get article1Preview;

  /// No description provided for @article1Caption.
  ///
  /// In en, this message translates to:
  /// **'Stay active to boost both body and brain. Skipping workouts means skipping your health.'**
  String get article1Caption;

  /// No description provided for @article1Content.
  ///
  /// In en, this message translates to:
  /// **'When people think about medicine, they usually imagine pills, capsules, or doctor\'s prescriptions. But here\'s the truth—one of the most powerful medicines you can ever give your body doesn\'t come from a pharmacy. It comes from movement. Exercise is the kind of medicine you can\'t skip, because it works on every part of your health, from your heart and lungs to your mood and mental clarity.\n\nThink about it: just 20–30 minutes of physical activity a day can improve blood circulation, strengthen muscles, and lower the risk of chronic diseases. But it\'s not just about the body—your brain benefits too. Regular workouts release endorphins, reduce stress, and even sharpen focus. In short, moving your body isn\'t just about staying fit; it\'s about staying alive and thriving.\n\nThe best part? You don\'t need an expensive gym membership or fancy equipment to start. A brisk walk, a quick home workout, or even stretching while watching TV can make a real difference. What matters most is consistency. Small steps done daily will bring more results than pushing yourself hard once a month.\n\nSo, the next time you feel like skipping exercise, remember this: you\'re not just skipping a workout—you\'re skipping an opportunity to invest in your future health. Treat movement like medicine, because your body and brain truly can\'t function at their best without it.'**
  String get article1Content;

  /// No description provided for @article2Title.
  ///
  /// In en, this message translates to:
  /// **'Healthy Plates, Healthy Life'**
  String get article2Title;

  /// No description provided for @article2Preview.
  ///
  /// In en, this message translates to:
  /// **'Balance your meals with color and variety. Small changes bring big results.'**
  String get article2Preview;

  /// No description provided for @article2Caption.
  ///
  /// In en, this message translates to:
  /// **'Balance your meals with color and variety. Small changes bring big results.'**
  String get article2Caption;

  /// No description provided for @article2Content.
  ///
  /// In en, this message translates to:
  /// **'A healthy lifestyle begins with the food you choose every day. Building a balanced plate doesn\'t have to be complicated—just focus on variety and moderation. By including colorful fruits and vegetables, lean proteins, whole grains, and healthy fats, you can give your body what it needs to stay strong and energized.\n\nThe more color you add to your meals, the more nutrients you introduce into your diet. Foods with rich natural colors—like leafy greens, carrots, berries, and peppers—are packed with vitamins, minerals, and antioxidants that support overall well-being. A colorful plate is not only healthier but also more enjoyable to eat.\n\nPortion control is another key to healthy eating. You don\'t need to remove all your favorite foods, but you can reduce excess sugar, salt, and unhealthy fats. Try using smaller plates, add more vegetables, and avoid overeating by listening to your body\'s hunger cues.\n\nSmall changes, like swapping white rice for brown rice or choosing grilled instead of fried foods, can make a big difference over time. These simple adjustments can support better digestion, stable energy levels, and improved long-term health.\n\nRemember that healthy eating is a journey, not a diet. The goal is progress—not perfection. When you make mindful choices consistently, you\'ll feel better, stronger, and more confident in your daily life.'**
  String get article2Content;

  /// No description provided for @article3Title.
  ///
  /// In en, this message translates to:
  /// **'Managing Glucose Made Simple'**
  String get article3Title;

  /// No description provided for @article3Preview.
  ///
  /// In en, this message translates to:
  /// **'With the right choices, you can stay energized and prevent risks. Your health matters.'**
  String get article3Preview;

  /// No description provided for @article3Caption.
  ///
  /// In en, this message translates to:
  /// **'With the right choices, you can stay energized and prevent risks. Your health is in your hands.'**
  String get article3Caption;

  /// No description provided for @article3Content.
  ///
  /// In en, this message translates to:
  /// **'Managing blood glucose doesn\'t have to be overwhelming. Understanding how food, physical activity, and daily habits affect your blood sugar can help you make better decisions. With the right approach, you can maintain stable energy levels and reduce the risk of long-term health problems.\n\nCarbohydrates have the biggest impact on blood sugar, so choosing the right type of carbs matters. Whole grains, beans, vegetables, and fruits offer slow and steady energy, unlike sugary snacks and processed foods that cause quick spikes and crashes. Balance is key—not elimination.\n\nRegular physical activity also helps your body use glucose more efficiently. Even simple movements like walking after meals, stretching, or doing light exercise can support healthier glucose levels. Consistency matters more than intensity.\n\nMonitoring your habits can help you understand what works best for your body. Pay attention to how certain meals, stress, or sleep patterns affect your energy. Small lifestyle adjustments can lead to big improvements.\n\nYou have the power to take control of your health. By making mindful choices every day, you can protect your well-being, stay active longer, and feel confident in managing your glucose levels.'**
  String get article3Content;

  /// No description provided for @article4Title.
  ///
  /// In en, this message translates to:
  /// **'Your Guide to Everyday Wellness'**
  String get article4Title;

  /// No description provided for @article4Preview.
  ///
  /// In en, this message translates to:
  /// **'Practical tips for a healthier, balanced life. Because health is wealth.'**
  String get article4Preview;

  /// No description provided for @article4Caption.
  ///
  /// In en, this message translates to:
  /// **'Practical tips for a healthier, balanced life. Because health is wealth.'**
  String get article4Caption;

  /// No description provided for @article4Content.
  ///
  /// In en, this message translates to:
  /// **'Wellness is not just about avoiding illness—it\'s about feeling your best physically, mentally, and emotionally. Taking simple steps each day can create a more balanced and fulfilling lifestyle. Healthy habits develop over time, one choice at a time.\n\nStart by fueling your body with nutritious food, staying hydrated, and maintaining regular meal patterns. A balanced diet supports stable moods, better focus, and improved immunity. Small habits like drinking enough water or choosing whole foods can make a big impact.\n\nMental wellness is just as important as physical health. Taking breaks, practicing mindfulness, journaling, or spending time in nature can help reduce stress and improve emotional balance. Don\'t forget to rest—quality sleep allows your body and mind to recover.\n\nMovement is another essential part of wellness. Whether it\'s walking, dancing, yoga, or sports, find activities you enjoy so exercise feels rewarding—not forced. A strong body helps support an active and independent life.\n\nMost importantly, be kind to yourself. Wellness is personal and different for everyone. Progress may be slow, but consistency will help you build habits that last a lifetime. Your health truly is your greatest wealth.'**
  String get article4Content;

  /// No description provided for @article5Title.
  ///
  /// In en, this message translates to:
  /// **'Move Daily, Live Stronger'**
  String get article5Title;

  /// No description provided for @article5Preview.
  ///
  /// In en, this message translates to:
  /// **'Simple routines can transform your energy and health. Make movement your daily medicine.'**
  String get article5Preview;

  /// No description provided for @article5Caption.
  ///
  /// In en, this message translates to:
  /// **'Simple routines can transform your energy and health. Make movement your daily medicine.'**
  String get article5Caption;

  /// No description provided for @article5Content.
  ///
  /// In en, this message translates to:
  /// **'Movement is one of the best gifts you can give your body. Daily physical activity strengthens your muscles, supports heart health, improves flexibility, and boosts mood. You don\'t need a gym membership—just start where you are.\n\nSimple routines like walking, stretching, or taking the stairs can make a meaningful difference. Even 10 minutes of movement can increase circulation, reduce stiffness, and give you more energy throughout the day.\n\nExercise also plays an important role in maintaining a healthy weight and managing blood sugar. When your body moves, it uses glucose as fuel, helping maintain balance and prevent spikes. Consistent movement keeps your metabolism active and efficient.\n\nRegular exercise benefits mental health as well. Physical activity triggers the release of endorphins—natural chemicals that reduce stress and increase happiness. Movement can help improve sleep, confidence, and overall mood.\n\nMake exercise something you look forward to, not a chore. Choose activities you enjoy, stay consistent, and celebrate small wins. The more you move, the stronger and healthier you become—one step at a time.'**
  String get article5Content;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get noArticlesFound;

  /// No description provided for @shareAsPost.
  ///
  /// In en, this message translates to:
  /// **'GlucoTrack Post'**
  String get shareAsPost;

  /// No description provided for @shareOptionsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose how to share your measurement results'**
  String get shareOptionsPrompt;

  /// No description provided for @shareAsPostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share as a post in GlucoTrack'**
  String get shareAsPostSubtitle;

  /// No description provided for @otherApps.
  ///
  /// In en, this message translates to:
  /// **'Other Apps'**
  String get otherApps;

  /// No description provided for @socialAppsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp, Instagram, Facebook, etc'**
  String get socialAppsSubtitle;

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing...'**
  String get sharing;

  /// No description provided for @bloodGlucoseResult.
  ///
  /// In en, this message translates to:
  /// **'Blood Glucose Measurement Result'**
  String get bloodGlucoseResult;

  /// No description provided for @iotDeviceInvasive.
  ///
  /// In en, this message translates to:
  /// **'IoT Device (Invasive)'**
  String get iotDeviceInvasive;

  /// No description provided for @manualGlucometer.
  ///
  /// In en, this message translates to:
  /// **'Manual Glucometer'**
  String get manualGlucometer;

  /// No description provided for @conditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition: '**
  String get conditionLabel;

  /// No description provided for @footerStayHealthy.
  ///
  /// In en, this message translates to:
  /// **'💙 Stay healthy with GlucoTrack'**
  String get footerStayHealthy;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @emailPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and Password are required.'**
  String get emailPasswordRequired;

  /// No description provided for @sessionNotActive.
  ///
  /// In en, this message translates to:
  /// **'Session not active. Try again.'**
  String get sessionNotActive;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get loginFailed;

  /// No description provided for @enterEmailReset.
  ///
  /// In en, this message translates to:
  /// **'Enter email for password reset.'**
  String get enterEmailReset;

  /// No description provided for @checkEmailReset.
  ///
  /// In en, this message translates to:
  /// **'Check your email for reset instructions.'**
  String get checkEmailReset;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your new account'**
  String get createAccount;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @emailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailEmpty;

  /// No description provided for @usernameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameEmpty;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select your birth date'**
  String get selectBirthDate;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation does not match'**
  String get passwordMismatch;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Check email/username or try again.'**
  String get registrationFailed;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please check your email.'**
  String get registrationSuccess;

  /// No description provided for @glucoseChart.
  ///
  /// In en, this message translates to:
  /// **'Glucose Chart'**
  String get glucoseChart;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @noDataDateRange.
  ///
  /// In en, this message translates to:
  /// **'No data for this date range'**
  String get noDataDateRange;

  /// No description provided for @noDataCategory.
  ///
  /// In en, this message translates to:
  /// **'No data for category \'\'{category}\'\''**
  String noDataCategory(String category);

  /// No description provided for @noHistoryData.
  ///
  /// In en, this message translates to:
  /// **'No history data yet'**
  String get noHistoryData;

  /// No description provided for @noDataAnalysis.
  ///
  /// In en, this message translates to:
  /// **'No data this week for analysis.'**
  String get noDataAnalysis;

  /// No description provided for @glucoseStability.
  ///
  /// In en, this message translates to:
  /// **'Blood Glucose Stability'**
  String get glucoseStability;

  /// No description provided for @attentionRequired.
  ///
  /// In en, this message translates to:
  /// **'Attention Required'**
  String get attentionRequired;

  /// No description provided for @highGlucoseTrend.
  ///
  /// In en, this message translates to:
  /// **'Your glucose trend is high this week. Over 50% of records are above normal.'**
  String get highGlucoseTrend;

  /// No description provided for @hypoglycemiaAlert.
  ///
  /// In en, this message translates to:
  /// **'Hypoglycemia Alert'**
  String get hypoglycemiaAlert;

  /// No description provided for @lowGlucoseTrend.
  ///
  /// In en, this message translates to:
  /// **'Frequent low glucose detected. Ensure regular meals and consult a doctor.'**
  String get lowGlucoseTrend;

  /// No description provided for @goodJob.
  ///
  /// In en, this message translates to:
  /// **'Good Job!'**
  String get goodJob;

  /// No description provided for @stableGlucoseMessage.
  ///
  /// In en, this message translates to:
  /// **'Your glucose is well-controlled this week. Keep up your healthy lifestyle.'**
  String get stableGlucoseMessage;

  /// No description provided for @fairlyStable.
  ///
  /// In en, this message translates to:
  /// **'Fairly Stable'**
  String get fairlyStable;

  /// No description provided for @stableVariationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your glucose variation is within reasonable limits. Average this week is {avg} mg/dL.'**
  String stableVariationMessage(String avg);

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @whoCanReply.
  ///
  /// In en, this message translates to:
  /// **'Who can reply?'**
  String get whoCanReply;

  /// No description provided for @whoCanReplySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick who can reply to this post.'**
  String get whoCanReplySubtitle;

  /// No description provided for @everyone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get everyone;

  /// No description provided for @followersOnly.
  ///
  /// In en, this message translates to:
  /// **'Followers Only'**
  String get followersOnly;

  /// No description provided for @discardPost.
  ///
  /// In en, this message translates to:
  /// **'Discard post?'**
  String get discardPost;

  /// No description provided for @discardPostMessage.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone and you\'ll lose your draft.'**
  String get discardPostMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @addNewPost.
  ///
  /// In en, this message translates to:
  /// **'Add New Post'**
  String get addNewPost;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @writeSomethingHere.
  ///
  /// In en, this message translates to:
  /// **'Write something here....'**
  String get writeSomethingHere;

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} character} other{{count} characters}}'**
  String characterCount(int count);

  /// No description provided for @manualGlucoseTask.
  ///
  /// In en, this message translates to:
  /// **'{count}x Manual Glucose Recording'**
  String manualGlucoseTask(int count);

  /// No description provided for @iotGlucoseTask.
  ///
  /// In en, this message translates to:
  /// **'{count}x IoT Glucose Recording'**
  String iotGlucoseTask(int count);

  /// No description provided for @socialPostTask.
  ///
  /// In en, this message translates to:
  /// **'{count}x Post updates on Social Feeds'**
  String socialPostTask(int count);

  /// No description provided for @tasksProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} Tasks'**
  String tasksProgress(int completed, int total);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} mins ago'**
  String minsAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @monitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get monitoring;

  /// No description provided for @allDataDisplayed.
  ///
  /// In en, this message translates to:
  /// **'All data displayed'**
  String get allDataDisplayed;

  /// No description provided for @noDataThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No data this week'**
  String get noDataThisWeek;

  /// No description provided for @noDataThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No data this month'**
  String get noDataThisMonth;

  /// No description provided for @yourMissions.
  ///
  /// In en, this message translates to:
  /// **'Your Missions'**
  String get yourMissions;

  /// No description provided for @optionalTaskInfo.
  ///
  /// In en, this message translates to:
  /// **'These tasks are optional. Complete them to get special rewards!'**
  String get optionalTaskInfo;

  /// No description provided for @manualGlucoseTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Blood Glucose Recording'**
  String get manualGlucoseTaskTitle;

  /// No description provided for @manualGlucoseTaskDesc.
  ///
  /// In en, this message translates to:
  /// **'Record your blood glucose level manually using a glucometer'**
  String get manualGlucoseTaskDesc;

  /// No description provided for @iotGlucoseTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'IoT Blood Glucose Recording'**
  String get iotGlucoseTaskTitle;

  /// No description provided for @iotGlucoseTaskDesc.
  ///
  /// In en, this message translates to:
  /// **'Record your blood glucose level using an IoT device'**
  String get iotGlucoseTaskDesc;

  /// No description provided for @socialPostTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Post on Social Feeds'**
  String get socialPostTaskTitle;

  /// No description provided for @socialPostTaskDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your experience on social feeds'**
  String get socialPostTaskDesc;

  /// No description provided for @seeDetail.
  ///
  /// In en, this message translates to:
  /// **'See Detail'**
  String get seeDetail;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get updateFailed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
