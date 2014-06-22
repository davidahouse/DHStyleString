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
provides a stylespec format that encapsulates the attributes in a JSON like format. Once a stylespec file
is created, there are methods to generate attributed strings from simple strings all the way up to very
complex text.

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

Once you have a stylespec file, you can create an instance of the DHStyleSpec class
to work with it. The DHStyleSpec has two main methods for converting raw strings into
attributed strings. The first method attributedString:style: converts a single string
with a single style into an attributed string.


```objectivec

  DHStyleSpec *spec = [[DHStyleSpec alloc] initWithName:@"test"];

  // Style a single string
  NSAttributedString *result = [spec attributedString:@"Can you dig it?"
                                                style:@"redBold"];
```

The second method for creating attributed strings is to use the DHStyleString class. This
class can be initialized from a resource file, or a string. The class can handle multiline
strings with embedded style tags, as well as replacement tags. Here is an example style string:

```objectivec
start
#{speaker:dynamic_row0}
#{+indented}#{+body}I'll call upon you straight: abide within.#{-body}
#{+italic}Exeunt Murderers#{-italic}

#{+body}It is concluded. Banquo, thy soul's flight,
If it find heaven, must find it out to-night.#{-body}
#{+italic}Exit#{-italic}#{-indented}
#{source}
end
```

All the style/replacement tags follow the format of #{...}. There are 4 possible
values that can go inside the braces:

* A single variable name that will be replaced from values passed in from a dictionary
when the string is built.
* A variable and a style, separated by a : character.
* A + with a style that causes the style to be applied to all subsequent strings, until
a matching - tag is seen.
* A - with a style that ends a style from being applied. Note that the style name here is
optional as this tag simply removes the last style that was added with the +.

Once the DHStyleString class has been initialized, the DHStyleSpec method attributedStringFromStyleString:variables:
can be called to generate the full attributed string.

```objectivec
DHStyleString *rawString = [[DHStyleString alloc] initWithName:@"mcbeth"];
DHStyleSpec *spec = [[DHStyleSpec alloc] initWithName:@"test"];
NSDictionary *variables = @{@"speaker":@"MACBETH",@"source":@"http://shakespeare.mit.edu/macbeth"};

NSAttributedString *result = [spec attributedStringFromStyleString:rawString variables:variables];
```

## Future Work

- Full documentation on the possible attributes in the stylespec file. For now, look at the test.stylespec
file that is included in the example project.
- Better error checking when parsing the files, especially the style string file.

## Author

David House, davidahouse@gmail.com

## License

StyleString is available under the MIT license. See the LICENSE file for more info.
