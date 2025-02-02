import 'package:intl/intl.dart';

class TimeUtils {
  static String getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  static String day(DateTime date) => date.day.toString();
  static String abbrWeekday(DateTime date) => date.abbrWeekday;
  static String weekday(DateTime date) => date.weekday.toString();
  static String abbrStandaloneMonth(DateTime date) => date.abbrStandaloneMonth;
  static String standaloneMonth(DateTime date) => date.standaloneMonth;
  static String numMonth(DateTime date) => date.numMonth;
  static String numMonthDay(DateTime date) => date.numMonthDay;
  static String numMonthWeekdayDay(DateTime date) => date.numMonthWeekdayDay;
  static String abbrMonth(DateTime date) => date.abbrMonth;
  static String abbrMonthDay(DateTime date) => date.abbrMonthDay;
  static String abbrMonthWeekdayDay(DateTime date) => date.abbrMonthWeekdayDay;
  static String month(DateTime date) => date.month.toString();
  static String monthDay(DateTime date) => date.monthDay;
  static String monthWeekdayDay(DateTime date) => date.monthWeekdayDay;
  static String abbrQuarter(DateTime date) => date.abbrQuarter;
  static String quarter(DateTime date) => date.quarter;
  static String year(DateTime date) => date.year.toString();
  static String yearNumMonth(DateTime date) => date.yearNumMonth;
  static String yearNumMonthDay(DateTime date) => date.yearNumMonthDay;
  static String yearNumMonthWeekdayDay(DateTime date) => date.yearNumMonthWeekdayDay;
  static String yearAbbrMonth(DateTime date) => date.yearAbbrMonth;
  static String yearAbbrMonthDay(DateTime date) => date.yearAbbrMonthDay;
  static String yearAbbrMonthWeekdayDay(DateTime date) => date.yearAbbrMonthWeekdayDay;
  static String yearMonth(DateTime date) => date.yearMonth;
  static String yearMonthDay(DateTime date) => date.yearMonthDay;
  static String yearMonthWeekdayDay(DateTime date) => date.yearMonthWeekdayDay;
  static String yearAbbrQuarter(DateTime date) => date.yearAbbrQuarter;
  static String yearQuarter(DateTime date) => date.yearQuarter;
  static String hour24(DateTime date) => date.hour24;
  static String hour24Minute(DateTime date) => date.hour24Minute;
  static String hour24MinuteSecond(DateTime date) => date.hour24MinuteSecond;
  static String hour(DateTime date) => date.hour.toString();
  static String hourMinute(DateTime date) => date.hourMinute;
  static String hourMinuteSecond(DateTime date) => date.hourMinuteSecond;
  static String minute(DateTime date) => date.minute.toString();
  static String minuteSecond(DateTime date) => date.minuteSecond;
  static String second(DateTime date) => date.second.toString();
  static String mmddyyyy(DateTime date) => date.mmddyyyy;
  static String ddmmyyyy(DateTime date) => date.ddmmyyyy;
  static String yyyymmdd(DateTime date) => date.yyyymmdd;
  static String fullDate(DateTime date) => date.fullDate;
  static String monthDayYear(DateTime date) => date.monthDayYear;
  static String monthAbbrDayYear(DateTime date) => date.monthAbbrDayYear;
  static String shortDate(DateTime date) => date.shortDate;
  static String iso8601(DateTime date) => date.iso8601;
  static String dayWithSuffix(DateTime date) => date.dayWithSuffix;
  static String monthDaySuffixYear(DateTime date) => date.monthDaySuffixYear;
  static String hourMinuteAmPm(DateTime date) => date.hourMinuteAmPm;
  static String hourMinuteSecondAmPm(DateTime date) => date.hourMinuteSecondAmPm;
  static String time24Hour(DateTime date) => date.time24Hour;
  static String time24HourWithSeconds(DateTime date) => date.time24HourWithSeconds;
}

// https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
extension DateTimeFormattingExtensions on DateTime {
  // Existing methods
  String get day => DateFormat('d').format(this); // e.g., "6"
  String get abbrWeekday => DateFormat('E').format(this); // e.g., "Thu"
  String get weekday => DateFormat('EEEE').format(this); // e.g., "Thursday"
  String get abbrStandaloneMonth => DateFormat('LLL').format(this); // e.g., "Jun"
  String get standaloneMonth => DateFormat('LLLL').format(this); // e.g., "June"
  String get numMonth => DateFormat('M').format(this); // e.g., "6"
  String get numMonthDay => DateFormat('Md').format(this); // e.g., "6/6"
  String get numMonthWeekdayDay => DateFormat('MEd').format(this); // e.g., "Thu, 6/6"
  String get abbrMonth => DateFormat('MMM').format(this); // e.g., "Jun"
  String get abbrMonthDay => DateFormat('MMMd').format(this); // e.g., "Jun 6"
  String get abbrMonthWeekdayDay => DateFormat('MMMEd').format(this); // e.g., "Thu, Jun 6"
  String get month => DateFormat('MMMM').format(this); // e.g., "June"
  String get monthDay => DateFormat('MMMMd').format(this); // e.g., "June 6"
  String get monthWeekdayDay => DateFormat('MMMMEEEEd').format(this); // e.g., "Thursday, June 6"
  String get abbrQuarter => DateFormat('QQQ').format(this); // e.g., "Q2"
  String get quarter => DateFormat('QQQQ').format(this); // e.g., "2nd quarter"
  String get year => DateFormat('y').format(this); // e.g., "2024"
  String get yearNumMonth => DateFormat('yM').format(this); // e.g., "6/2024"
  String get yearNumMonthDay => DateFormat('yMd').format(this); // e.g., "6/6/2024"
  String get yearNumMonthWeekdayDay => DateFormat('yMEd').format(this); // e.g., "Thu, 6/6/2024"
  String get yearAbbrMonth => DateFormat('yMMM').format(this); // e.g., "Jun 2024"
  String get yearAbbrMonthDay => DateFormat('yMMMd').format(this); // e.g., "Jun 6, 2024"
  String get yearAbbrMonthWeekdayDay => DateFormat('yMMMEd').format(this); // e.g., "Thu, Jun 6, 2024"
  String get yearMonth => DateFormat('yMMMM').format(this); // e.g., "June 2024"
  String get yearMonthDay => DateFormat('yMMMMd').format(this); // e.g., "June 6, 2024"
  String get yearMonthWeekdayDay => DateFormat('yMMMMEEEEd').format(this); // e.g., "Thursday, June 6, 2024"
  String get yearAbbrQuarter => DateFormat('yQQQ').format(this); // e.g., "Q2 2024"
  String get yearQuarter => DateFormat('yQQQQ').format(this); // e.g., "2nd quarter 2024"
  String get hour24 => DateFormat('H').format(this); // e.g., "14"
  String get hour24Minute => DateFormat('Hm').format(this); // e.g., "14:30"
  String get hour24MinuteSecond => DateFormat('Hms').format(this); // e.g., "14:30:45"
  String get hour => DateFormat('j').format(this); // e.g., "2 PM"
  String get hourMinute => DateFormat('jm').format(this); // e.g., "2:30 PM"
  String get hourMinuteSecond => DateFormat('jms').format(this); // e.g., "2:30:45 PM"
  String get minute => DateFormat('m').format(this); // e.g., "30"
  String get minuteSecond => DateFormat('ms').format(this); // e.g., "30:45"
  String get second => DateFormat('s').format(this); // e.g., "45"

  // Additional common date formats
  String get mmddyyyy => DateFormat('MM/dd/yyyy').format(this); // e.g., "06/06/2024"
  String get ddmmyyyy => DateFormat('dd/MM/yyyy').format(this); // e.g., "06/06/2024"
  String get yyyymmdd => DateFormat('yyyy-MM-dd').format(this); // e.g., "2024-06-06"
  String get fullDate => DateFormat('EEEE, MMMM d, yyyy').format(this); // e.g., "Thursday, June 6, 2024"
  String get monthDayYear => DateFormat('MMMM d, yyyy').format(this); // e.g., "June 6, 2024"
  String get monthAbbrDayYear => DateFormat('MMM d, yyyy').format(this); // e.g., "Jun 6, 2024"
  String get shortDate => DateFormat('M/d/yy').format(this); // e.g., "6/6/24"
  String get iso8601 => DateFormat('yyyy-MM-ddTHH:mm:ss').format(this); // e.g., "2024-06-06T14:30:45"

  // Helper method to get day with ordinal suffix (e.g., 1st, 2nd, 3rd)
  String get dayWithSuffix {
    int dayNum = this.day;
    String suffix;

    if (dayNum >= 11 && dayNum <= 13) {
      suffix = 'th';
    } else {
      switch (dayNum % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }
    return '$dayNum$suffix'; // e.g., "6th"
  }

  // Format: June 6th, 2024
  String get monthDaySuffixYear {
    String month = DateFormat('MMMM').format(this); // e.g., "June"
    String daySuffix = this.dayWithSuffix; // e.g., "6th"
    String year = DateFormat('yyyy').format(this); // e.g., "2024"
    return '$month $daySuffix, $year'; // e.g., "June 6th, 2024"
  }

  // Additional time formats
  String get hourMinuteAmPm => DateFormat('hh:mm a').format(this); // e.g., "02:30 PM"
  String get hourMinuteSecondAmPm => DateFormat('hh:mm:ss a').format(this); // e.g., "02:30:45 PM"
  String get time24Hour => DateFormat('HH:mm').format(this); // e.g., "14:30"
  String get time24HourWithSeconds => DateFormat('HH:mm:ss').format(this); // e.g., "14:30:45"
}
