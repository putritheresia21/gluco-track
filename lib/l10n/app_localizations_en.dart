import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GlucoTrack';

  @override
  String get hello => 'Hello,';

  @override
  String get totalRecords => 'Total Records';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String get lowest => 'Lowest';

  @override
  String get highest => 'Highest';

  @override
  String get yourMission => 'Your Mission';

  @override
  String get viewAll => 'view all';

  @override
  String get notifications => 'Notifications';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get logoutConfirm => 'Logout Confirmation';

  @override
  String get logoutMessage => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logout => 'Logout';

  @override
  String yearsOld(int age) {
    return '$age years old';
  }

  @override
  String get points => 'Points';

  @override
  String get daysStreak => 'Days Streak';

  @override
  String get missionsCompleted => 'Missions Completed';

  @override
  String get yourNextMission => 'Your Next Mission';

  @override
  String get noMissionsAvailable => 'No missions available';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get mgDl => 'mg/dL';

  @override
  String get loading => 'Loading...';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get beforeMeal => 'Before Meal';

  @override
  String get afterMeal => 'After Meal';

  @override
  String get at => 'at';

  @override
  String get shareResult => 'Share Result';

  @override
  String get shareResultMessage => 'Do you want to share your current blood glucose test results?';

  @override
  String get no => 'No';

  @override
  String get yesShare => 'Yes, Share';

  @override
  String get selectDateTimeFirst => 'Select date and time first.';

  @override
  String get glucoseDataSaved => 'Glucose data saved successfully.';

  @override
  String get failedSaveDatabase => 'Failed to save data to database.';

  @override
  String failedSaveData(String error) {
    return 'Failed to save data: $error';
  }

  @override
  String get glucoseRecord => 'Glucose Record';

  @override
  String get glucoseLevelMgDl => 'Blood Glucose Level (mg/dL)';

  @override
  String get glucoseLevelRequired => 'Glucose level cannot be empty';

  @override
  String get validNumberRequired => 'Enter a valid number';

  @override
  String get iotDataLoaded => 'IoT data loaded successfully';

  @override
  String get automatic => 'Automatic';

  @override
  String get iotDeviceData => 'IoT Device Data';

  @override
  String get measurementCondition => 'Measurement Condition';

  @override
  String get useCurrentTime => 'Use Current Time';

  @override
  String get selectDateTime => 'Select Date & Time';

  @override
  String get dateTime => 'Date & Time: ';

  @override
  String get save => 'Save';

  @override
  String whatsUp(String name) {
    return 'What\'s up, $name!';
  }

  @override
  String get haveAnythingToShare => 'Have anything to share?';

  @override
  String get searchHint => 'Search posts, articles, or users...';

  @override
  String get forYou => 'For you';

  @override
  String get news => 'News';

  @override
  String get failedTriggerEsp32 => 'Failed to send trigger to ESP32';

  @override
  String get timeoutEsp32 => 'Timeout: ESP32 not responding';

  @override
  String get measureAgain => 'Measure Again';

  @override
  String get startMeasurement => 'Start Measurement';

  @override
  String get checkGlucoseNow => 'Check your glucose now!';

  @override
  String get start => 'Start';

  @override
  String get measurementProcess => 'Measurement Process';

  @override
  String get measurementResult => 'Measurement Result';

  @override
  String get confidence => 'Confidence: ';

  @override
  String get continueText => 'Continue';

  @override
  String get measurementFailed => 'Measurement Failed';

  @override
  String get articleDetail => 'Article\'s Detail';

  @override
  String get social => 'Social';

  @override
  String get socialMediaFeed => 'Social Media Feed';

  @override
  String get iotConnection => 'IoT Connection';

  @override
  String get testingSocialMedia => 'testing social media';

  @override
  String get writeSomethingFirst => 'Write something first';

  @override
  String get posted => 'Posted!';

  @override
  String failedToPost(String error) {
    return 'Failed to post: $error';
  }

  @override
  String get post => 'Post';

  @override
  String failedToLoadFeed(String error) {
    return 'Failed to load feed: $error';
  }

  @override
  String get writeSomethingOrAddImage => 'Write something or add an image';

  @override
  String failedToCreateImage(String error) {
    return 'Failed to create image: $error';
  }

  @override
  String failedToShare(String error) {
    return 'Failed to share: $error';
  }

  @override
  String congratulationsPoints(int points) {
    return 'Congratulations! You earned $points points';
  }

  @override
  String get failedToClaimPoints => 'Failed to claim points';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get article1Title => 'Exercise: The Medicine You Can\'t Skip.';

  @override
  String get article1Preview => 'Stay active to boost both body and brain. Skipping workouts means missing your health.';

  @override
  String get article1Caption => 'Stay active to boost both body and brain. Skipping workouts means skipping your health.';

  @override
  String get article1Content => 'When people think about medicine, they usually imagine pills, capsules, or doctor\'s prescriptions. But here\'s the truth—one of the most powerful medicines you can ever give your body doesn\'t come from a pharmacy. It comes from movement. Exercise is the kind of medicine you can\'t skip, because it works on every part of your health, from your heart and lungs to your mood and mental clarity.\n\nThink about it: just 20–30 minutes of physical activity a day can improve blood circulation, strengthen muscles, and lower the risk of chronic diseases. But it\'s not just about the body—your brain benefits too. Regular workouts release endorphins, reduce stress, and even sharpen focus. In short, moving your body isn\'t just about staying fit; it\'s about staying alive and thriving.\n\nThe best part? You don\'t need an expensive gym membership or fancy equipment to start. A brisk walk, a quick home workout, or even stretching while watching TV can make a real difference. What matters most is consistency. Small steps done daily will bring more results than pushing yourself hard once a month.\n\nSo, the next time you feel like skipping exercise, remember this: you\'re not just skipping a workout—you\'re skipping an opportunity to invest in your future health. Treat movement like medicine, because your body and brain truly can\'t function at their best without it.';

  @override
  String get article2Title => 'Healthy Plates, Healthy Life';

  @override
  String get article2Preview => 'Balance your meals with color and variety. Small changes bring big results.';

  @override
  String get article2Caption => 'Balance your meals with color and variety. Small changes bring big results.';

  @override
  String get article2Content => 'A healthy lifestyle begins with the food you choose every day. Building a balanced plate doesn\'t have to be complicated—just focus on variety and moderation. By including colorful fruits and vegetables, lean proteins, whole grains, and healthy fats, you can give your body what it needs to stay strong and energized.\n\nThe more color you add to your meals, the more nutrients you introduce into your diet. Foods with rich natural colors—like leafy greens, carrots, berries, and peppers—are packed with vitamins, minerals, and antioxidants that support overall well-being. A colorful plate is not only healthier but also more enjoyable to eat.\n\nPortion control is another key to healthy eating. You don\'t need to remove all your favorite foods, but you can reduce excess sugar, salt, and unhealthy fats. Try using smaller plates, add more vegetables, and avoid overeating by listening to your body\'s hunger cues.\n\nSmall changes, like swapping white rice for brown rice or choosing grilled instead of fried foods, can make a big difference over time. These simple adjustments can support better digestion, stable energy levels, and improved long-term health.\n\nRemember that healthy eating is a journey, not a diet. The goal is progress—not perfection. When you make mindful choices consistently, you\'ll feel better, stronger, and more confident in your daily life.';

  @override
  String get article3Title => 'Managing Glucose Made Simple';

  @override
  String get article3Preview => 'With the right choices, you can stay energized and prevent risks. Your health matters.';

  @override
  String get article3Caption => 'With the right choices, you can stay energized and prevent risks. Your health is in your hands.';

  @override
  String get article3Content => 'Managing blood glucose doesn\'t have to be overwhelming. Understanding how food, physical activity, and daily habits affect your blood sugar can help you make better decisions. With the right approach, you can maintain stable energy levels and reduce the risk of long-term health problems.\n\nCarbohydrates have the biggest impact on blood sugar, so choosing the right type of carbs matters. Whole grains, beans, vegetables, and fruits offer slow and steady energy, unlike sugary snacks and processed foods that cause quick spikes and crashes. Balance is key—not elimination.\n\nRegular physical activity also helps your body use glucose more efficiently. Even simple movements like walking after meals, stretching, or doing light exercise can support healthier glucose levels. Consistency matters more than intensity.\n\nMonitoring your habits can help you understand what works best for your body. Pay attention to how certain meals, stress, or sleep patterns affect your energy. Small lifestyle adjustments can lead to big improvements.\n\nYou have the power to take control of your health. By making mindful choices every day, you can protect your well-being, stay active longer, and feel confident in managing your glucose levels.';

  @override
  String get article4Title => 'Your Guide to Everyday Wellness';

  @override
  String get article4Preview => 'Practical tips for a healthier, balanced life. Because health is wealth.';

  @override
  String get article4Caption => 'Practical tips for a healthier, balanced life. Because health is wealth.';

  @override
  String get article4Content => 'Wellness is not just about avoiding illness—it\'s about feeling your best physically, mentally, and emotionally. Taking simple steps each day can create a more balanced and fulfilling lifestyle. Healthy habits develop over time, one choice at a time.\n\nStart by fueling your body with nutritious food, staying hydrated, and maintaining regular meal patterns. A balanced diet supports stable moods, better focus, and improved immunity. Small habits like drinking enough water or choosing whole foods can make a big impact.\n\nMental wellness is just as important as physical health. Taking breaks, practicing mindfulness, journaling, or spending time in nature can help reduce stress and improve emotional balance. Don\'t forget to rest—quality sleep allows your body and mind to recover.\n\nMovement is another essential part of wellness. Whether it\'s walking, dancing, yoga, or sports, find activities you enjoy so exercise feels rewarding—not forced. A strong body helps support an active and independent life.\n\nMost importantly, be kind to yourself. Wellness is personal and different for everyone. Progress may be slow, but consistency will help you build habits that last a lifetime. Your health truly is your greatest wealth.';

  @override
  String get article5Title => 'Move Daily, Live Stronger';

  @override
  String get article5Preview => 'Simple routines can transform your energy and health. Make movement your daily medicine.';

  @override
  String get article5Caption => 'Simple routines can transform your energy and health. Make movement your daily medicine.';

  @override
  String get article5Content => 'Movement is one of the best gifts you can give your body. Daily physical activity strengthens your muscles, supports heart health, improves flexibility, and boosts mood. You don\'t need a gym membership—just start where you are.\n\nSimple routines like walking, stretching, or taking the stairs can make a meaningful difference. Even 10 minutes of movement can increase circulation, reduce stiffness, and give you more energy throughout the day.\n\nExercise also plays an important role in maintaining a healthy weight and managing blood sugar. When your body moves, it uses glucose as fuel, helping maintain balance and prevent spikes. Consistent movement keeps your metabolism active and efficient.\n\nRegular exercise benefits mental health as well. Physical activity triggers the release of endorphins—natural chemicals that reduce stress and increase happiness. Movement can help improve sleep, confidence, and overall mood.\n\nMake exercise something you look forward to, not a chore. Choose activities you enjoy, stay consistent, and celebrate small wins. The more you move, the stronger and healthier you become—one step at a time.';

  @override
  String get noArticlesFound => 'No articles found';

  @override
  String get shareAsPost => 'GlucoTrack Post';

  @override
  String get shareOptionsPrompt => 'Choose how to share your measurement results';

  @override
  String get shareAsPostSubtitle => 'Share as a post in GlucoTrack';

  @override
  String get otherApps => 'Other Apps';

  @override
  String get socialAppsSubtitle => 'WhatsApp, Instagram, Facebook, etc';

  @override
  String get sharing => 'Sharing...';

  @override
  String get bloodGlucoseResult => 'Blood Glucose Measurement Result';

  @override
  String get iotDeviceInvasive => 'IoT Device (Invasive)';

  @override
  String get manualGlucometer => 'Manual Glucometer';

  @override
  String get conditionLabel => 'Condition: ';

  @override
  String get footerStayHealthy => '💙 Stay healthy with GlucoTrack';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginToAccount => 'Login to your account';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get emailPasswordRequired => 'Email and Password are required.';

  @override
  String get sessionNotActive => 'Session not active. Try again.';

  @override
  String get loginFailed => 'Login failed.';

  @override
  String get enterEmailReset => 'Enter email for password reset.';

  @override
  String get checkEmailReset => 'Check your email for reset instructions.';

  @override
  String get createAccount => 'Create your new account';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get createPassword => 'Create a password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get emailEmpty => 'Email cannot be empty';

  @override
  String get usernameEmpty => 'Username cannot be empty';

  @override
  String get selectBirthDate => 'Select your birth date';

  @override
  String get passwordMismatch => 'Password confirmation does not match';

  @override
  String get registrationFailed => 'Registration failed. Check email/username or try again.';

  @override
  String get registrationSuccess => 'Registration successful! Please check your email.';

  @override
  String get glucoseChart => 'Glucose Chart';

  @override
  String get history => 'History';

  @override
  String get selectDate => 'Pilih Tanggal';

  @override
  String get all => 'Semua';

  @override
  String get low => 'Low';

  @override
  String get normal => 'Normal';

  @override
  String get high => 'High';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get noDataDateRange => 'No data for this date range';

  @override
  String noDataCategory(String category) {
    return 'No data for category \'\'$category\'\'';
  }

  @override
  String get noHistoryData => 'No history data yet';

  @override
  String get noDataAnalysis => 'No data this week for analysis.';

  @override
  String get glucoseStability => 'Blood Glucose Stability';

  @override
  String get attentionRequired => 'Attention Required';

  @override
  String get highGlucoseTrend => 'Your glucose trend is high this week. Over 50% of records are above normal.';

  @override
  String get hypoglycemiaAlert => 'Hypoglycemia Alert';

  @override
  String get lowGlucoseTrend => 'Frequent low glucose detected. Ensure regular meals and consult a doctor.';

  @override
  String get goodJob => 'Good Job!';

  @override
  String get stableGlucoseMessage => 'Your glucose is well-controlled this week. Keep up your healthy lifestyle.';

  @override
  String get fairlyStable => 'Fairly Stable';

  @override
  String stableVariationMessage(String avg) {
    return 'Your glucose variation is within reasonable limits. Average this week is $avg mg/dL.';
  }

  @override
  String get average => 'Average';

  @override
  String get whoCanReply => 'Who can reply?';

  @override
  String get whoCanReplySubtitle => 'Pick who can reply to this post.';

  @override
  String get everyone => 'Everyone';

  @override
  String get followersOnly => 'Followers Only';

  @override
  String get discardPost => 'Discard post?';

  @override
  String get discardPostMessage => 'This can\'t be undone and you\'ll lose your draft.';

  @override
  String get discard => 'Discard';

  @override
  String get addNewPost => 'Add New Post';

  @override
  String get share => 'Share';

  @override
  String get writeSomethingHere => 'Write something here....';

  @override
  String characterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count characters',
      one: '$count character',
    );
    return '$_temp0';
  }

  @override
  String manualGlucoseTask(int count) {
    return '${count}x Manual Glucose Recording';
  }

  @override
  String iotGlucoseTask(int count) {
    return '${count}x IoT Glucose Recording';
  }

  @override
  String socialPostTask(int count) {
    return '${count}x Post updates on Social Feeds';
  }

  @override
  String tasksProgress(int completed, int total) {
    return '$completed/$total Tasks';
  }

  @override
  String get completed => 'Completed';

  @override
  String get claim => 'Claim';

  @override
  String get justNow => 'Just now';

  @override
  String minsAgo(int count) {
    return '$count mins ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }
}
