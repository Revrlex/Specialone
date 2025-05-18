class DateTimeUtils {
  /// İki zaman aralığının çakışıp çakışmadığını kontrol eder
  /// Her görev 1 saat sürer kabul edilecek
  static bool isTimeConflict(DateTime task1DateTime, DateTime task2DateTime) {
    // Aynı gün olup olmadığını kontrol et
    final isSameDay = task1DateTime.year == task2DateTime.year &&
        task1DateTime.month == task2DateTime.month &&
        task1DateTime.day == task2DateTime.day;

    if (!isSameDay) {
      return false; // Farklı günlerdeyse çakışma yok
    }

    // İki görev arasında en az 1 saat olup olmadığını kontrol et
    final task1End = task1DateTime.add(const Duration(hours: 1));
    final task2End = task2DateTime.add(const Duration(hours: 1));

    // Çakışma kontrolü:
    // task1'in başlangıcı task2'nin sonundan önce VE
    // task1'in sonu task2'nin başlangıcından sonra ise
    return task1DateTime.isBefore(task2End) && task1End.isAfter(task2DateTime);
  }

  /// Verilen tarih ve saat değerlerini birleştirerek tek bir DateTime nesnesi oluşturur
  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  /// İki DateTime nesnesinin aynı gün olup olmadığını kontrol eder
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Verilen DateTime nesnesinden sadece saat ve dakika bilgilerini içeren TimeOfDay nesnesi oluşturur
  static TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Bildirim zamanını görev zamanından belirli bir süre önce olacak şekilde hesaplar
  static DateTime getNotificationTime(DateTime taskDateTime, {int minutesBefore = 15}) {
    return taskDateTime.subtract(Duration(minutes: minutesBefore));
  }
}