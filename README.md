# StyleString

[![Version](https://img.shields.io/cocoapods/v/StyleString.svg?style=flat)](http://cocoadocs.org/docsets/StyleString)
[![License](https://img.shields.io/cocoapods/l/StyleString.svg?style=flat)](http://cocoadocs.org/docsets/StyleString)
[![Platform](https://img.shields.io/cocoapods/p/StyleString.svg?style=flat)](http://cocoadocs.org/docsets/StyleString)

## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Requirements

This library is intended for iOS 7.0 and above.

## Installation

StyleString is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "StyleString"

## Description

Creating all the attribute dictionaries and then applying them to strings to create a NSAttributedString
object is very tedious and a lot of code. Taking a small cue from how CSS works, the StyleString library
provides a stylespec format that encapsulates the attributes in a JSON like format, then a category
on NSAttributedString to combine raw strings with these styles to create a formatted string.

To use this library, create a stylespec text file and add to your project. Inside this file you can create
as many styles as you want, and styles can inherit from other styles. Here is a small example:

```json

rightaligned {
  "NSParagraphStyle": {
    "alignment": "right"
  }
}

redBold : rightaligned {
  "NSColor": "0xFF0000",
  "NSFont": {
    "boldSystemFontOfSize": "18"
  }
}

```

Once you have a stylespec file, you can use it by importing the NSAttributedString+StyleString.h header
and using once of its methods.

```objectivec

  // Style a single string using the first .stylespec file it can find
  NSAttributedString *result = [NSAttributedString SS_attributedString:@"Can you dig it?" style:@"redBold"];

  // Style a single string using a specific .stylespec file
  NSAttributedString *result = [NSAttributedString SS_attributedString:@"Can you dig it?" style:@"redBold" stylespec:@"mystyles"];

  // Combine multiple strings together and apply a different style to each
  NSAttributedString *result = [NSAttributedString SS_attributedStrings:@[@"Can you dig it?",@"I knew that you could."]
                                                                 styles:@[@"redBold",@"rightaligned"]];

  // Combine multiple strings together and apply a different style to each. And again with a specific stylespec file
  NSAttributedString *result = [NSAttributedString SS_attributedStrings:@[@"Can you dig it?",@"I knew that you could."]
                                                               styles:@[@"redBold",@"rightaligned"]
                                                            stylespec:@"mystyles"];
```

## Future Work

- Full documentation on the possible attributes in the stylespec file
- Methods for applying a style to a range in an existing string
- Methods for specifying a style in a bunch of text using a token replacement scheme

## Author

David House, davidahouse@gmail.com

## License

StyleString is available under the MIT license. See the LICENSE file for more info.
