import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls the language used for Fluentian's app chrome and explanation-language
/// variants of the French course content.
class AppLocaleController extends ChangeNotifier {
  static const _storageKey = 'fluentian_app_locale';
  Locale _locale = const Locale('en');
  static String activeLanguageCode = 'en';
  static String get activeLanguageName => switch (activeLanguageCode) {
    'am' => 'Amharic',
    'om' => 'Afaan Oromo',
    _ => 'English',
  };

  Locale get locale => _locale;

  AppLocaleController() {
    _restore();
  }

  Future<void> _restore() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(_storageKey);
    if (code == 'am' || code == 'om' || code == 'en') {
      _locale = Locale(code!);
      activeLanguageCode = code;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode)) return;
    _locale = Locale(locale.languageCode);
    activeLanguageCode = locale.languageCode;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, _locale.languageCode);
  }

  static const supportedLanguageCodes = {'en', 'am', 'om'};
  static const supportedLocales = [Locale('en'), Locale('am'), Locale('om')];
}

extension AppLocalizationContext on BuildContext {
  String tr(String source) =>
      AppCopy.translate(Localizations.localeOf(this).languageCode, source);
}

/// Text widget for static UI. It safely falls back to the supplied English copy
/// while a new screen is being translated, so dynamic API content is untouched.
class LText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const LText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) => Text(
    context.tr(data),
    style: style,
    strutStyle: strutStyle,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaler: textScaler,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
    selectionColor: selectionColor,
  );
}

class AppCopy {
  static String translate(String locale, String source) {
    if (locale == 'en') return source;
    return _copy[locale]?[source] ?? source;
  }

  static const Map<String, Map<String, String>> _copy = {
    'am': {
      'Learn': 'ተማር',
      'Community': 'ማህበረሰብ',
      'Home': 'መነሻ',
      'Explore': 'ያስሱ',
      'Live': 'ቀጥታ',
      'Board': 'ሰሌዳ',
      'Social': 'ማህበራዊ',
      'Profile': 'መገለጫ',
      'Settings': 'ቅንብሮች',
      'App language': 'የመተግበሪያ ቋንቋ',
      'Learning language': 'የመማሪያ ቋንቋ',
      'Your settings': 'የእርስዎ ቅንብሮች',
      'Learning': 'ትምህርት',
      'Audio': 'ድምፅ',
      'Notifications': 'ማሳወቂያዎች',
      'Accessibility': 'ተደራሽነት',
      'Privacy & account': 'ግላዊነት እና መለያ',
      'Daily goal': 'የዕለት ግብ',
      'Saved offline — XP will update after sync':
          'ከመስመር ውጭ ተቀምጧል — XP ከማመሳሰል በኋላ ይዘምናል',
      'Phonetic hints': 'የአነባበብ ጥቆማዎች',
      'Speaking exercises': 'የንግግር ልምምዶች',
      'Auto-play lesson audio': 'የትምህርት ድምፅን በራስ-ሰር አጫውት',
      'Sound effects': 'የድምፅ ውጤቶች',
      'TTS speed': 'የድምፅ ፍጥነት',
      'Allow notifications': 'ማሳወቂያዎችን ፍቀድ',
      'Daily lesson reminder': 'የዕለት ትምህርት አስታዋሽ',
      'Reminder time': 'የአስታዋሽ ሰዓት',
      'New Board opportunities': 'አዲስ የሰሌዳ ዕድሎች',
      'Test notification': 'ማሳወቂያ ሞክር',
      'Font size': 'የፊደል መጠን',
      'High contrast': 'ከፍተኛ ንፅፅር',
      'Reduce animations': 'እንቅስቃሴዎችን ቀንስ',
      'Haptic feedback': 'የንክኪ ምላሽ',
      'Privacy policy': 'የግላዊነት መመሪያ',
      'Delete my account': 'መለያዬን ሰርዝ',
      'Sign out': 'ውጣ',
      'Explore France': 'ፈረንሳይን ያስሱ',
      'Stories, sounds, and everyday culture': 'ታሪኮች፣ ድምፆች እና ዕለታዊ ባህል',
      'My word bank': 'የቃላት ባንኬ',
      'Tap any sentence to reveal its translation. Long press a paragraph for the full translation.':
          'ትርጉሙን ለማየት ማንኛውንም ሐረግ ይንኩ። ሙሉ ትርጉሙን ለማየት አንቀጹን ተጭነው ይቆዩ።',
      'MY MOMENTUM': 'የእኔ እድገት',
      'AT A GLANCE': 'በአጭሩ',
      'LEARNING RHYTHM': 'የትምህርት ሂደት',
      'Level progress': 'የደረጃ እድገት',
      'Learning summary': 'የትምህርት ማጠቃለያ',
      'Units completed': 'የተጠናቀቁ ክፍሎች',
      'Personalize my profile': 'መገለጫዬን አበጅ',
      'TODAY': 'ዛሬ',
      'DAILY CHALLENGE': 'የዕለት ፈተና',
      'Daily Review Time!': 'የዕለት ግምገማ ጊዜ!',
      'Review': 'ገምግም',
      'View all lessons': 'ሁሉንም ትምህርቶች ይመልከቱ',
      'Start': 'ጀምር',
      'You’re all caught up': 'ሁሉንም አጠናቅቀዋል',
      'Continue': 'ቀጥል',
      'Microphone access': 'የማይክሮፎን ፈቃድ',
      'Camera and microphone access': 'የካሜራ እና ማይክሮፎን ፈቃድ',
      'Fluentian uses your microphone only while you are in this speaking room. Live audio is sent to the other participant through LiveKit and is not recorded by Fluentian.':
          'Fluentian ማይክሮፎንዎን የሚጠቀመው በዚህ የንግግር ክፍል ውስጥ ሲሆኑ ብቻ ነው። የቀጥታ ድምፅ በLiveKit በኩል ለሌላው ተሳታፊ ይላካል፤ Fluentian ጥሪውን አይቀዳም።',
      'Fluentian uses your camera and microphone only while you are in this speaking room. Live audio and video are sent to the other participant through LiveKit and are not recorded by Fluentian.':
          'Fluentian ካሜራዎንና ማይክሮፎንዎን የሚጠቀመው በዚህ የንግግር ክፍል ውስጥ ሲሆኑ ብቻ ነው። የቀጥታ ድምፅና ቪዲዮ በLiveKit በኩል ለሌላው ተሳታፊ ይላካሉ፤ Fluentian ጥሪውን አይቀዳም።',
      'Back': 'ተመለስ',
      'Next': 'ቀጣይ',
      'Skip': 'ዝለል',
      'Close': 'ዝጋ',
      'Cancel': 'ሰርዝ',
      'Save': 'አስቀምጥ',
      'Edit': 'አርትዕ',
      'Search': 'ፈልግ',
      'Send': 'ላክ',
      'Sign in': 'ግባ',
      'Sign up': 'ተመዝገብ',
      'Create account': 'መለያ ፍጠር',
      'Get started': 'ጀምር',
      'Email': 'ኢሜይል',
      'Password': 'የይለፍ ቃል',
      'Username': 'የተጠቃሚ ስም',
      "Don't have an account? ": 'መለያ የለዎትም? ',
      'Already have an account? ': 'መለያ አለዎት? ',
      'We sent a verification code to ': 'የማረጋገጫ ኮድ ወደዚህ ልከናል፦ ',
      '. Enter it below along with your new password.':
          'ከአዲሱ የይለፍ ቃልዎ ጋር ከታች ያስገቡት።',
      'We sent a 6-digit code to ': 'ባለ 6 አሃዝ ኮድ ወደዚህ ልከናል፦ ',
      '. Enter it below to verify your account.': 'መለያዎን ለማረጋገጥ ከታች ያስገቡት።',
      'Challenge': 'ፈተና',
      'Placement test': 'የደረጃ መለያ ፈተና',
      'Mark all read': 'ሁሉንም እንደተነበበ ምልክት ያድርጉ',
      'Refresh': 'አድስ',
      'Retry': 'እንደገና ሞክር',
      'Try again': 'እንደገና ሞክር',
      'Try Again': 'እንደገና ሞክር',
      'Dismiss': 'ዝጋ',
      'Error': 'ስህተት',
      'Got it': 'ገባኝ',
      'Not now': 'አሁን አይደለም',
      'Save to my word bank': 'ወደ የቃላት ባንኬ አስቀምጥ',
      'Listen': 'አዳምጥ',
      'Hear sentence': 'ዓረፍተ ነገሩን አዳምጥ',
      'Send feedback': 'አስተያየት ላክ',
      'Leave lesson feedback': 'ስለ ትምህርቱ አስተያየት ይስጡ',
      'Find classmates': 'የክፍል ጓደኞችን ያግኙ',
      'Send challenge': 'ፈተና ላክ',
      'Team up': 'ቡድን ይሁኑ',
      'Send invitation': 'ግብዣ ላክ',
      'Keep account': 'መለያውን አቆይ',
      'Delete permanently': 'በቋሚነት ሰርዝ',
      'Delete your account?': 'መለያዎን ይሰርዙ?',
      'Remove': 'አስወግድ',
      'End partnership': 'ትብብሩን ጨርስ',
      'Block this learner': 'ይህን ተማሪ አግድ',
      'Submit confidential report': 'ሚስጥራዊ ሪፖርት አስገባ',
      'Application submitted successfully!': 'ማመልከቻዎ በተሳካ ሁኔታ ተልኳል!',
      'Could not save profile.': 'መገለጫውን ማስቀመጥ አልተቻለም።',
      'Failed to save profile': 'መገለጫውን ማስቀመጥ አልተሳካም',
      'Could not save setting.': 'ቅንብሩን ማስቀመጥ አልተቻለም።',
      'Could not play audio': 'ድምፁን ማጫወት አልተቻለም',
      'Failed to load audio.': 'ድምፁን መጫን አልተሳካም።',
      'Failed to load lesson.': 'ትምህርቱን መጫን አልተሳካም።',
      'No questions found.': 'ጥያቄዎች አልተገኙም።',
      'Please enter all 6 digits.': 'እባክዎ ሁሉንም 6 አሃዞች ያስገቡ።',
      'Please enter your email address.': 'እባክዎ የኢሜይል አድራሻዎን ያስገቡ።',
      'Please fill in all fields.': 'እባክዎ ሁሉንም መስኮች ይሙሉ።',
      'Marie — AI Coach': 'ማሪ — AI አሰልጣኝ',
      'A2 · Free conversation': 'A2 · ነፃ ውይይት',
      'Free chat': 'ነፃ ውይይት',
      'Roleplay': 'ሚና ጨዋታ',
      'Grammar drill': 'የሰዋሰው ልምምድ',
      'Pronunciation': 'አነባበብ',
      'Exam prep': 'የፈተና ዝግጅት',
      'Culture': 'ባህል',
      'Write a sentence in French': 'በፈረንሳይኛ ዓረፍተ ነገር ይጻፉ',
      'Marie is ready with hints, corrections, and examples':
          'ማሪ በጥቆማዎች፣ እርማቶች እና ምሳሌዎች ዝግጁ ናት',
      'AI Tutor': 'AI አስተማሪ',
      'Get hints, examples, and cleaner explanations':
          'ጥቆማዎችን፣ ምሳሌዎችን እና ግልጽ ማብራሪያዎችን ያግኙ',
      'Explain simply': 'በቀላሉ አብራራ',
      'Give example': 'ምሳሌ ስጥ',
      'Quiz me': 'ፈትነኝ',
      'Ask why, request an example, or get a hint':
          'ምክንያቱን ይጠይቁ፣ ምሳሌ ይፈልጉ ወይም ጥቆማ ያግኙ',
      'Quick poll': 'ፈጣን ምርጫ',
      'Mini quiz': 'አጭር ፈተና',
      'Correct!': 'ትክክል!',
      'Good try.': 'ጥሩ ሙከራ።',
      'Tutor is thinking': 'አስተማሪው እያሰበ ነው',
      'The AI tutor is unavailable. Please try again.':
          'የAI አስተማሪው አሁን አይገኝም። እባክዎ እንደገና ይሞክሩ።',
    },
    'om': {
      'Learn': 'Baradhu',
      'Community': 'Hawaasa',
      'Home': 'Mana',
      'Explore': 'Qoradhu',
      'Live': 'Kallattiin',
      'Board': 'Gabatee',
      'Social': 'Hawaasummaa',
      'Profile': 'Odeeffannoo Koo',
      'Settings': 'Qindaa’inoota',
      'App language': 'Afaan appii',
      'Learning language': 'Afaan barnootaa',
      'Your settings': 'Qindaa’inoota kee',
      'Learning': 'Barnoota',
      'Audio': 'Sagalee',
      'Notifications': 'Beeksisa',
      'Accessibility': 'Argamummaa',
      'Privacy & account': 'Iccitii fi herrega',
      'Daily goal': 'Galma guyyaa',
      'Saved offline — XP will update after sync':
          'Sarara ala kuufame — XP erga wal-simsiifamee booda haaromfama',
      'Phonetic hints': 'Gorsa sagalee',
      'Speaking exercises': 'Shaakala dubbii',
      'Auto-play lesson audio': 'Sagalee barnootaa ofumaan taphachiisi',
      'Sound effects': 'Bu’aalee sagalee',
      'TTS speed': 'Saffisa sagalee',
      'Allow notifications': 'Beeksisawwan hayyami',
      'Daily lesson reminder': 'Yaadachiisa barnoota guyyaa',
      'Reminder time': 'Yeroo yaadachiisaa',
      'New Board opportunities': 'Carraawwan haaraa Gabatee',
      'Test notification': 'Beeksisa yaali',
      'Font size': 'Hammamtaa qubee',
      'High contrast': 'Walmadaallii olaanaa',
      'Reduce animations': 'Sochiiwwan xiqqeessi',
      'Haptic feedback': 'Deebii tuquu',
      'Privacy policy': 'Imaammata iccitii',
      'Delete my account': 'Herrega koo haqi',
      'Sign out': 'Ba’i',
      'Explore France': 'Faransaayii qoradhu',
      'Stories, sounds, and everyday culture':
          'Seenaawwan, sagaleewwan fi aadaa guyyaa guyyaa',
      'My word bank': 'Kuusaa jechoota koo',
      'Tap any sentence to reveal its translation. Long press a paragraph for the full translation.':
          'Hiika isaa arguuf hima kamiyyuu tuqi. Hiika guutuu arguuf keewwata irratti dheeraan cuqaasi.',
      'MY MOMENTUM': 'DADAMAAQIIN KOO',
      'AT A GLANCE': 'GABAABAATTI',
      'LEARNING RHYTHM': 'SIRNA BARNOOTAA',
      'Level progress': 'Adeemsa sadarkaa',
      'Learning summary': 'Cuunfaa barnootaa',
      'Units completed': 'Kutaa xumuraman',
      'Personalize my profile': 'Odeeffannoo koo qindeessi',
      'TODAY': 'HAR’A',
      'DAILY CHALLENGE': 'QORUMSA GUYYAA',
      'Daily Review Time!': 'Yeroo irra-deebii guyyaa!',
      'Review': 'Irra deebi’i',
      'View all lessons': 'Barnoota hunda ilaali',
      'Start': 'Jalqabi',
      'You’re all caught up': 'Hunda xumurteetta',
      'Continue': 'Itti fufi',
      'Microphone access': 'Hayyama maayikiroofonii',
      'Camera and microphone access': 'Hayyama kaameraa fi maayikiroofonii',
      'Fluentian uses your microphone only while you are in this speaking room. Live audio is sent to the other participant through LiveKit and is not recorded by Fluentian.':
          'Fluentian maayikiroofonii kee kan fayyadamu yeroo ati kutaa dubbii kana keessa jirtu qofa. Sagaleen kallattii LiveKit keessatti hirmaataa biraatti ergama; Fluentian bilbila kana hin waraabu.',
      'Fluentian uses your camera and microphone only while you are in this speaking room. Live audio and video are sent to the other participant through LiveKit and are not recorded by Fluentian.':
          'Fluentian kaameraa fi maayikiroofonii kee kan fayyadamu yeroo ati kutaa dubbii kana keessa jirtu qofa. Sagalee fi viidiyoon kallattii LiveKit keessatti hirmaataa biraatti ergamu; Fluentian bilbila kana hin waraabu.',
      'Back': 'Deebi’i',
      'Next': 'Itti aanu',
      'Skip': 'Darbi',
      'Close': 'Cufi',
      'Cancel': 'Haqi',
      'Save': 'Kuusi',
      'Edit': 'Gulaali',
      'Search': 'Barbaadi',
      'Send': 'Ergi',
      'Sign in': 'Seeni',
      'Sign up': 'Galmaa’i',
      'Create account': 'Herrega uumi',
      'Get started': 'Jalqabi',
      'Email': 'Imeelii',
      'Password': 'Jecha icciitii',
      'Username': 'Maqaa fayyadamaa',
      "Don't have an account? ": 'Herrega hin qabduu? ',
      'Already have an account? ': 'Herrega qabdaa? ',
      'We sent a verification code to ':
          'Koodii mirkaneessaa kanaaf ergineerra: ',
      '. Enter it below along with your new password.':
          'Jecha icciitii haaraa keetii wajjin gaditti galchi.',
      'We sent a 6-digit code to ':
          'Koodii lakkoofsa 6 qabu kanaaf ergineerra: ',
      '. Enter it below to verify your account.':
          'Herrega kee mirkaneessuuf gaditti galchi.',
      'Challenge': 'Qorumsa',
      'Placement test': 'Qormaata sadarkaa',
      'Mark all read': 'Hunda akka dubbifameetti mallatteessi',
      'Refresh': 'Haaromsi',
      'Retry': 'Irra deebi’i yaali',
      'Try again': 'Irra deebi’i yaali',
      'Try Again': 'Irra deebi’i yaali',
      'Dismiss': 'Cufi',
      'Error': 'Dogoggora',
      'Got it': 'Naaf gale',
      'Not now': 'Amma miti',
      'Save to my word bank': 'Kuusaa jechoota kootti kaa’i',
      'Listen': 'Dhaggeeffadhu',
      'Hear sentence': 'Hima dhaggeeffadhu',
      'Send feedback': 'Yaada ergi',
      'Leave lesson feedback': 'Yaada barnootaa kenni',
      'Find classmates': 'Hiriyoota kutaa barbaadi',
      'Send challenge': 'Qorumsa ergi',
      'Team up': 'Garee ta’i',
      'Send invitation': 'Afeerraa ergi',
      'Keep account': 'Herrega tursiisi',
      'Delete permanently': 'Guutummaatti haqi',
      'Delete your account?': 'Herrega kee haquu barbaaddaa?',
      'Remove': 'Haqi',
      'End partnership': 'Waliin hojjechuu xumuri',
      'Block this learner': 'Barataa kana uggi',
      'Submit confidential report': 'Gabaasa iccitii ergi',
      'Application submitted successfully!':
          'Iyyannoon kee milkaa’inaan ergameera!',
      'Could not save profile.': 'Odeeffannoo kee kuusuu hin dandeenye.',
      'Failed to save profile': 'Odeeffannoo kee kuusuun hin milkoofne',
      'Could not save setting.': 'Qindaa’ina kuusuu hin dandeenye.',
      'Could not play audio': 'Sagalee taphachiisuu hin dandeenye',
      'Failed to load audio.': 'Sagalee fe’uun hin milkoofne.',
      'Failed to load lesson.': 'Barnoota fe’uun hin milkoofne.',
      'No questions found.': 'Gaaffileen hin argamne.',
      'Please enter all 6 digits.': 'Mee lakkoofsa 6 hunda galchi.',
      'Please enter your email address.': 'Mee teessoo imeelii kee galchi.',
      'Please fill in all fields.': 'Mee dirree hunda guuti.',
      'Marie — AI Coach': 'Marie — Leenjisaa AI',
      'A2 · Free conversation': 'A2 · Haasaa bilisaa',
      'Free chat': 'Haasaa bilisaa',
      'Roleplay': 'Gahee taphachuu',
      'Grammar drill': 'Shaakala seerlugaa',
      'Pronunciation': 'Akkaataa sagaleessuu',
      'Exam prep': 'Qophii qormaataa',
      'Culture': 'Aadaa',
      'Write a sentence in French': 'Hima Afaan Faransaayiitiin barreessi',
      'Marie is ready with hints, corrections, and examples':
          'Marie gorsa, sirreeffamaa fi fakkeenya waliin qophoofteetti',
      'AI Tutor': 'Barsiisaa AI',
      'Get hints, examples, and cleaner explanations':
          'Gorsa, fakkeenya fi ibsa ifa ta’e argadhu',
      'Explain simply': 'Salphaatti ibsi',
      'Give example': 'Fakkeenya kenni',
      'Quiz me': 'Na qori',
      'Ask why, request an example, or get a hint':
          'Maaliif akka ta’e gaafadhu, fakkeenya yookaan gorsa argadhu',
      'Quick poll': 'Filannoo saffisaa',
      'Mini quiz': 'Qormaata gabaabaa',
      'Correct!': 'Sirrii!',
      'Good try.': 'Yaalii gaarii.',
      'Tutor is thinking': 'Barsiisaan yaadaa jira',
      'The AI tutor is unavailable. Please try again.':
          'Barsiisaan AI amma hin argamu. Mee irra deebi’ii yaali.',
    },
  };
}
