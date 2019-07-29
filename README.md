# Table Calendar

[![Pub Package](https://img.shields.io/pub/v/table_calendar.svg?style=flat-square)](https://pub.dartlang.org/packages/table_calendar)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-52bdeb.svg?longCache=true&style=flat-square)](https://github.com/Solido/awesome-flutter)

Highly customizable, feature-packed Flutter Calendar with gestures, animations and multiple formats.

| ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/table_calendar_styles.gif) | ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/table_calendar_builders.gif) |
| :------------: | :------------: |
| **Table Calendar** with custom styles | **Table Calendar** with Builders |

## Features

* Extensive, yet easy to use API
* Custom Builders for truly flexible UI
* Complete programmatic control with CalendarController
* Interface for holidays
* Locale support
* Vertical autosizing
* Beautiful animations
* Gesture handling
* Multiple Calendar formats
* Multiple days of the week formats
* Specifying available date range
* Nice, configurable UI out of the box

## Usage

Make sure to check out [example project](https://github.com/aleksanderwozniak/table_calendar/tree/master/example). 
For additional info please refer to [API docs](https://pub.dartlang.org/documentation/table_calendar/latest/table_calendar/table_calendar-library.html).

### Installation

Add to pubspec.yaml:

```yaml
dependencies:
  table_calendar: ^2.0.0
```

Then import it to your project:

```dart
import 'package:table_calendar/table_calendar.dart';
```

And finally create the **TableCalendar** with a `CalendarController`:

```dart
@override
void initState() {
  super.initState();
  _calendarController = CalendarController();
}

@override
void dispose() {
  _calendarController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return TableCalendar(
    calendarController: _calendarController,
  );
}
```

### Locale

**Table Calendar** supports locales. To display the Calendar in desired language, use `locale` property. 
If you don't specify it, a default locale will be used.

#### Initialization

Before you can use a locale, you need to initialize the i18n formatting.

*This is independent of **Table Calendar** package, so I encourage you to do your own research.*

A simple way of doing it is as follows:
* First of all, add [intl](https://pub.dartlang.org/packages/intl) package to your pubspec.yaml file
* Then make modifications to your `main()`:

```dart
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}
```

After those two steps your app should be ready to use **Table Calendar** with different languages.

#### Specifying a language

To specify a language, simply pass it as a String code to `locale` property.

For example, this will make **Table Calendar** use Polish language:

```dart
TableCalendar(
  locale: 'pl_PL',
),
```

| ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/en_US.png) | ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/pl_PL.png) | ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/fr_FR.png) | ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/zh_CN.png) |
| :------------: | :------------: | :------------: | :------------: |
| `'en_US'` | `'pl_PL'` | `'fr_FR'` | `'zh_CN'` |

Note, that if you want to change the language of `FormatButton`'s text, you have to do this yourself. Use `availableCalendarFormats` property and pass the translated Strings there. 
Use i18n method of your choice.

You can also hide the button altogether by setting `formatButtonVisible` to false.

### Holidays

**Table Calendar** provides a simple interface for displaying holidays. Here are a few steps to follow:

* Fetch a map of holidays tied to dates. You can search for it manually, or perhaps use some online API
* Convert it to a proper format - note that these are lists of holidays, since one date could have a couple of holidays: 
```dart
{
  `DateTime A`: [`Holiday A1`, `Holiday A2`, ...],
  `DateTime B`: [`Holiday B1`, `Holiday B2`, ...],
  ...
}
```
* Link it to **Table Calendar**. Use `holidays` property

And that's your basic setup! Now you can add some styling:

* By using `CalendarStyle` properties: `holidayStyle` and `outsideHolidayStyle`
* By using `CalendarBuilders` for complete UI control over calendar cell

You can also add custom holiday markers thanks to improved marker API. Check out [example project](https://github.com/aleksanderwozniak/table_calendar/tree/master/example) for more details.

```dart
markersBuilder: (context, date, events, holidays) {
  final children = <Widget>[];

  if (events.isNotEmpty) {
    children.add(
      Positioned(
        right: 1,
        bottom: 1,
        child: _buildEventsMarker(date, events),
      ),
    );
  }

  if (holidays.isNotEmpty) {
    children.add(
      Positioned(
        right: -2,
        top: -2,
        child: _buildHolidaysMarker(),
      ),
    );
  }

  return children;
},
```