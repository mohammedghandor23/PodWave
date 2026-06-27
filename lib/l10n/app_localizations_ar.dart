// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'PodWave';

  @override
  String get home => 'الرئيسية';

  @override
  String get library => 'المكتبة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get yourMusicOffline => 'موسيقاك، بدون إنترنت.';

  @override
  String get nowPlaying => 'المشغل الآن';

  @override
  String get queue => 'قائمة الانتظار';

  @override
  String get songs => 'الأغاني';

  @override
  String get albums => 'الألبومات';

  @override
  String get artists => 'الفنانون';

  @override
  String get playlists => 'قوائم التشغيل';

  @override
  String get search => 'بحث';

  @override
  String get searchInLibrary => 'ابحث عن أغاني...';

  @override
  String get recentlyPlayed => 'شغلت مؤخراً';

  @override
  String get mostPlayed => 'الأكثر تشغيلاً';

  @override
  String get recentlyAdded => 'أضيف مؤخراً';

  @override
  String get favorites => 'المفضلة';

  @override
  String get folderNotFound => 'المجلد غير موجود';

  @override
  String get noSongsInFolder => 'لا توجد أغاني في هذا المجلد';

  @override
  String get noAlbumsFound => 'لا توجد ألبومات';

  @override
  String get noSongsFound => 'لا توجد أغاني';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String get error => 'خطأ';

  @override
  String get refresh => 'تحديث';

  @override
  String songCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أغنية',
      one: 'أغنية',
    );
    return '$count $_temp0';
  }

  @override
  String get customizeYourAuditoryExperience => 'خصص تجربتك السمعية.';

  @override
  String get playback => 'التشغيل';

  @override
  String get resumePlayback => 'استئناف التشغيل';

  @override
  String get autoPlayWhenAppOpens => 'تشغيل تلقائي عند فتح التطبيق';

  @override
  String get resumeModePrompt => 'السؤال للاستئناف';

  @override
  String get resumeModePromptDesc => 'عرض حوار عند استئناف الأغاني';

  @override
  String get resumeModeAuto => 'استئناف تلقائي';

  @override
  String get resumeModeAutoDesc => 'الاستئناف تلقائياً من الموضع المحفوظ';

  @override
  String get system => 'النظام';

  @override
  String get localStorage => 'التخزين المحلي';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get resumeDialogTitle => 'استئناف التشغيل؟';

  @override
  String resumeDialogMessage(String position) {
    return 'توقفت عند $position. الاستئناف من هناك؟';
  }

  @override
  String get resume => 'استئناف';

  @override
  String get startOver => 'البداية من جديد';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get newPlaylist => 'قائمة جديدة';

  @override
  String get createPlaylist => 'إنشاء قائمة تشغيل';

  @override
  String get playlistName => 'اسم القائمة';

  @override
  String get playlistNameHint => 'قائمتي';

  @override
  String get create => 'إنشاء';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get addSongs => 'إضافة أغاني';

  @override
  String get noPlaylists => 'لا توجد قوائم بعد';

  @override
  String get noSongsInPlaylist => 'لا توجد أغاني في هذه القائمة';

  @override
  String get emptyPlaylist => 'هذه القائمة فارغة';

  @override
  String get addSongsToPlaylist => 'أضف أغاني إلى هذه القائمة';

  @override
  String get done => 'تم';

  @override
  String get deletePlaylistConfirm => 'حذف هذه القائمة؟';

  @override
  String songsSelected(int count) {
    return '$count محدد';
  }
}
