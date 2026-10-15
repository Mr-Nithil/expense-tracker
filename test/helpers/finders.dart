import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Like `find.text`, but also matches text shown differently from what is announced: the Sprout
/// buttons show "SAVE" with the screen-reader label "Save" (M12.2). Matches a [Text] whose text
/// or semantics label is [text], and an [EditableText] containing [text].
Finder findText(String text, {bool skipOffstage = true}) => find.byWidgetPredicate(
  (widget) => switch (widget) {
    Text(:final data, :final semanticsLabel) => data == text || semanticsLabel == text,
    EditableText(:final controller) => controller.text == text,
    _ => false,
  },
  description: 'text "$text"',
  skipOffstage: skipOffstage,
);

/// Like `find.widgetWithText`, using [findText].
Finder findWidgetWithText(Type type, String text, {bool skipOffstage = true}) => find.ancestor(
  of: findText(text, skipOffstage: skipOffstage),
  matching: find.byType(type, skipOffstage: skipOffstage),
);
