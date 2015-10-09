<p align="center" >
  <img src="LOGO.png" title="Navajo logo" float=left height="120px" width="120px">
</p>

# Navajo-Swift

**Password Validator & Strength Evaluator**

> Navajo is named in honor of the famed [code talkers of the Second World War](http://en.wikipedia.org/wiki/Code_talker#Navajo_code_talkers).

## Original Project

[Navajo](https://github.com/mattt/Navajo) by Mattt Thompson

> This project is not 100% compatible with the original project.

## Installation

[![Swift 2.0](https://img.shields.io/badge/Swift-2.0-orange.svg?style=flat)](https://developer.apple.com/swift)
[![Platform iOS](https://img.shields.io/badge/Platform-iOS-red.svg?style=flat)](http://www.apple.com/ios)
[![Travis-CI](https://travis-ci.org/jasonnam/Navajo-Swift.svg?branch=master)](https://travis-ci.org/jasonnam/Navajo-Swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Navajo-Swift.svg?style=flat)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/cocoapods/v/Navajo-Swift.svg?style=flat)](https://cocoapods.org/pods/Navajo-Swift)

### CocoaPods

```ruby
use_frameworks!
pod 'Navajo-Swift'
```

```swift
import Navajo_Swift
```

### Manual

Just copy the files in Source folder into your project.

## Usage

### Evaluating Password Strength

> Password strength is evaluated in terms of [information entropy](http://en.wikipedia.org/wiki/Entropy_%28information_theory%29).

```swift
@IBOutlet weak var passwordField: UITextField! = nil
@IBOutlet weak var strengthLabel: UILabel! = nil

strengthLabel.text = Navajo.localizedStringForPasswordStrength(Navajo.strengthOfPassword(passwordField.text))
```

### Validating Password

```swift
var lengthRule = NJOLengthRule(min: 6, max: 24)
var uppercaseRule = NJORequiredCharacterRule(preset: .LowercaseCharacter)

validator = NJOPasswordValidator(rules: [lengthRule, uppercaseRule])

var failingRules = validator.validatePassword("PASSWORD")

if failingRules == nil
{
    NSLog("The password is valid.")
}
else
{
    var errorMessage = ""

    for var i = 0; i < failingRules!.count; i++
    {
        if i > 1
        {
            errorMessage += ("\n" + failingRules![i].localizedErrorDescription())
        }
        else
        {
            errorMessage += failingRules![i].localizedErrorDescription()
        }
    }

    NSLog("\(errorMessage)")
}
```

#### Available Validation Rules

- Allowed Characters
- Required Characters (custom, lowercase, uppercase, decimal, symbol)
- Non-Dictionary Word
- Minimum / Maximum Length
- Predicate Match
- Regular Expression Match
- Block Evaluation

If you are using the Predicate and Regex rules, remember that when password is matching to them it is considered to be invalid. For example, we can check if users are using for example "password123" as their password by following rule object.

```swift
var rule = NJOPredicateRule(predicate: NSPredicate(format: "SELF BEGINSWITH %@", "PASSWORD"))
```

For the block rule, it is considered to be invalid when the block returns true.

### Localization

Keys for the localizable strings
[Localization Tutorial](http://rshankar.com/internationalization-and-localization-of-apps-in-xcode-6-and-swift/) or check the demo app in the repository.

#### Password Strength

- NAVAJO_VERY_WEAK
- NAVAJO_WEAK
- NAVAJO_REASONABLE
- NAVAJO_STRONG
- NAVAJO_VERY_STRONG

#### Password Validation

- NAVAJO_ALLOWED_CHARACTER_ERROR

- NAVAJO_REQUIRED_CHARACTER_REQUIRED_ERROR
- NAVAJO_REQUIRED_CHARACTER_LOWERCASE_ERROR
- NAVAJO_REQUIRED_CHARACTER_UPPERCASE_ERROR
- NAVAJO_REQUIRED_CHARACTER_DECIMAL_DIGIT_ERROR
- NAVAJO_REQUIRED_CHARACTER_SYMBOL_ERROR

- NAVAJO_DICTIONARYWORD_ERROR
- NAVAJO_LENGTH_ERROR
- NAVAJO_PREDICATE_ERROR
- NAVAJO_REGEX_ERROR
- NAVAJO_BLOCK_ERROR

## Contact

Any feedback and pull requests are welcome :)

Jason Nam<br>[Website](http://www.jasonnam.com)<br>[Email](mailto:contact@jasonnam.com)

## License

Navajo-Swift is available under the MIT license. See the LICENSE file for more info.
