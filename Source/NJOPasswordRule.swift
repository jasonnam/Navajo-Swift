//
// NJOPasswordRule.swift
// Navajo
//
// Copyright (c) 2015-2016 Jason Nam (http://www.jasonnam.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
#if os(OSX)
    import CoreServices
#else
    import UIKit
#endif

/// By adopting NJOPasswordRule protocol you can build your own rules.
public protocol NJOPasswordRule {
    /// Evaluating the password
    ///
    /// - parameter password: Password string to be evaluated
    ///
    /// - returns: true is considered to be failed and false is passed.
    func evaluate(_ password: String) -> Bool

    /// Error description
    var localizedErrorDescription: String { get }
}

/// NJORequiredCharacterRulePreset makes initializing NJORequiredCharacterRule easy.
public enum NJORequiredCharacterRulePreset {
    /// Password should contain at least one lowercase character.
    case lowercaseCharacter
    /// Password should contain at least one uppercase character.
    case uppercaseCharacter
    /// Password should contain at least one decimal digit character.
    case decimalDigitCharacter
    /// Password should contain at least one symbol character.
    case symbolCharacter
}

/// NJOAllowedCharacterRule checks if the password only has allowed characters.
open class NJOAllowedCharacterRule: NSObject, NJOPasswordRule {
    open var disallowedCharacters: CharacterSet? = nil

    /// Initialize with an NSCharacterSet object.
    public convenience init(characterSet: CharacterSet) {
        self.init()
        disallowedCharacters = characterSet.inverted
    }

    /// Evaluate password. Return false if it is passed and true if failed.
    open func evaluate(_ password: String) -> Bool {
        guard let disallowedCharacters = disallowedCharacters else {
            return false
        }

        return (password as NSString).rangeOfCharacter(from: disallowedCharacters).location != NSNotFound
    }

    /// Error description. 
    /// Localization Key - "NAVAJO_ALLOWED_CHARACTER_ERROR"
    open var localizedErrorDescription: String {
        return NSLocalizedString("NAVAJO_ALLOWED_CHARACTER_ERROR", tableName: nil, bundle: Bundle.main, value: "Must not include disallowed character", comment: "Navajo - Allowed character rule")
    }
}

/// NJORequiredCharacterRule checks if the password contains at least one required character.
open class NJORequiredCharacterRule: NSObject, NJOPasswordRule {
    private var requiredCharacterSetToCompare: CharacterSet? = nil

    open var requiredCharacterSet: CharacterSet? = nil {
        didSet {
            if let requiredCharacterSet = requiredCharacterSet {
                preset = nil
                updateRequiredCharacterSetToCompare(with: requiredCharacterSet)
            }
        }
    }

    open var preset: NJORequiredCharacterRulePreset? = nil {
        didSet {
            if let preset = preset {
                requiredCharacterSet = nil
                updateRequiredCharacterSetToCompare(with: preset)
            }
        }
    }

    /// Initialize with an NJORequiredCharacterRulePreset object.
    public convenience init(preset: NJORequiredCharacterRulePreset) {
        self.init()
        self.preset = preset
        updateRequiredCharacterSetToCompare(with: preset)
    }

    /// Initialize with an NSCharacterSet object.
    public convenience init(characterSet: CharacterSet) {
        self.init()
        requiredCharacterSet = characterSet
        updateRequiredCharacterSetToCompare(with: characterSet)
    }

    private func updateRequiredCharacterSetToCompare(with requiredCharacterSet: CharacterSet) {
        requiredCharacterSetToCompare = requiredCharacterSet
    }

    private func updateRequiredCharacterSetToCompare(with preset: NJORequiredCharacterRulePreset) {
        switch preset {
        case .lowercaseCharacter:
            requiredCharacterSetToCompare = CharacterSet.lowercaseLetters
        case .uppercaseCharacter:
            requiredCharacterSetToCompare = CharacterSet.uppercaseLetters
        case .decimalDigitCharacter:
            requiredCharacterSetToCompare = CharacterSet.decimalDigits
        case .symbolCharacter:
            var symbolCharacterSet = CharacterSet.symbols
            symbolCharacterSet.formUnion(CharacterSet.punctuationCharacters)
            requiredCharacterSetToCompare = symbolCharacterSet
        }
    }

    /// Evaluate password. Return false if it is passed and true if failed.
    open func evaluate(_ password: String) -> Bool {
        guard let requiredCharacterSetToCompare = requiredCharacterSetToCompare else {
            return false
        }

        return (password as NSString).rangeOfCharacter(from: requiredCharacterSetToCompare).location == NSNotFound
    }

    /// Error description.
    /// Localization keys
    /// - Lowercase error "NAVAJO_REQUIRED_CHARACTER_LOWERCASE_ERROR"
    /// - Uppercase error "NAVAJO_REQUIRED_CHARACTER_UPPERCASE_ERROR"
    /// - Decimal digit error "NAVAJO_REQUIRED_CHARACTER_DECIMAL_DIGIT_ERROR"
    /// - Symbol error "NAVAJO_REQUIRED_CHARACTER_SYMBOL_ERROR"
    /// - Default error "NAVAJO_REQUIRED_CHARACTER_REQUIRED_ERROR"
    open var localizedErrorDescription: String {
        if let preset = preset {
            switch preset {
            case .lowercaseCharacter:
                return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_LOWERCASE_ERROR", tableName: nil, bundle: Bundle.main, value: "Must include lowercase characters", comment: "Navajo - Required lowercase character rule")
            case .uppercaseCharacter:
                return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_UPPERCASE_ERROR", tableName: nil, bundle: Bundle.main, value: "Must include uppercase characters", comment: "Navajo - Required uppercase character rule")
            case .decimalDigitCharacter:
                return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_DECIMAL_DIGIT_ERROR", tableName: nil, bundle: Bundle.main, value: "Must include decimal digit characters", comment: "Navajo - Required decimal digit character rule")
            case .symbolCharacter:
                return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_SYMBOL_ERROR", tableName: nil, bundle: Bundle.main, value: "Must include symbol characters", comment: "Navajo - Required symbol character rule")
            }
        } else {
            return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_REQUIRED_ERROR", tableName: nil, bundle: Bundle.main, value: "Must include required characters", comment: "Navajo - Required character rule")
        }
    }
}

/// NJODictionaryWordRule checks if the password can be found on the OSX or iOS dictionary.
open class NJODictionaryWordRule: NSObject, NJOPasswordRule {
    private let nonLowercaseCharacterSet = CharacterSet.lowercaseLetters.inverted

    /// Evaluate password. Return false if it is passed and true if failed.
    open func evaluate(_ password: String) -> Bool {
        #if os(OSX)
            return DCSGetTermRangeInString(nil, password as CFString, 0).location != kCFNotFound
        #else
            return UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: password.lowercased().trimmingCharacters(in: nonLowercaseCharacterSet))
        #endif
    }

    /// Error description.
    /// Localization Key - "NAVAJO_DICTIONARYWORD_ERROR"
    open var localizedErrorDescription: String {
        return NSLocalizedString("NAVAJO_DICTIONARYWORD_ERROR", tableName: nil, bundle: Bundle.main, value: "Must not be dictionary word", comment: "Navajo - Dictionary word rule")
    }
}

/// NJOLengthRule checks the length of password.
open class NJOLengthRule: NSObject, NJOPasswordRule {
    open var range: NSRange? = nil

    /// Initialize with minimum and maximum values.
    public convenience init(min: Int, max: Int) {
        self.init()
        range = NSMakeRange(min, max - min + 1)
    }

    /// Evaluate password. Return false if it is passed and true if failed.
    open func evaluate(_ password: String) -> Bool {
        guard let range = range else {
            return false
        }

        return !NSLocationInRange(password.characters.count, range)
    }

    /// Error description.
    /// Localization Key - "NAVAJO_LENGTH_ERROR"
    open var localizedErrorDescription: String {
        var rangeDescription = "nil"

        if let range = range {
            rangeDescription = NSStringFromRange(range)
        }

        return NSLocalizedString("NAVAJO_LENGTH_ERROR", tableName: nil, bundle: Bundle.main, value: "Must be within range ", comment: "Navajo - Length rule") + rangeDescription
    }
}

/// NJOPredicateRule checks password with a NSPredicate object.
open class NJOPredicateRule: NSObject, NJOPasswordRule {
    open var predicate: NSPredicate? = nil

    /// Initialize with an NSPredicate object.
    public convenience init(predicate: NSPredicate) {
        self.init()
        self.predicate = predicate
    }

    /// Evaluate password. Return false if it is passed and true if failed.
    open func evaluate(_ password: String) -> Bool {
        guard let predicate = predicate else {
            return false
        }

        return predicate.evaluate(with: password)
    }

    /// Error description.
    /// Localization Key - "NAVAJO_PREDICATE_ERROR"
    open var localizedErrorDescription: String {
        return NSLocalizedString("NAVAJO_PREDICATE_ERROR", tableName: nil, bundle: Bundle.main, value: "Must not match predicate", comment: "Navajo - Predicate rule")
    }
}

/// NJORegularExpressionRule checks password with a NSRegularExpression object.
open class NJORegularExpressionRule: NSObject, NJOPasswordRule {
    open var regularExpression: NSRegularExpression? = nil

    /// Initialize with an NSRegularExpression object.
    public convenience init(regularExpression: NSRegularExpression) {
        self.init()
        self.regularExpression = regularExpression
    }

    /// Evaluate password. Return false if it is passed and true if failed.
    open func evaluate(_ password: String) -> Bool {
        guard let regularExpression = regularExpression else {
            return false
        }

        return regularExpression.numberOfMatches(in: password, options: [], range: NSMakeRange(0, password.characters.count)) > 0
    }

    /// Error description.
    /// Localization Key - "NAVAJO_REGEX_ERROR"
    open var localizedErrorDescription: String {
        return NSLocalizedString("NAVAJO_REGEX_ERROR", tableName: nil, bundle: Bundle.main, value: "Must not match regular expression", comment: "Navajo - Regex rule")
    }
}

/// NJOBlockRule checks password with a block which gets a string and returns a bool value.
open class NJOBlockRule: NSObject, NJOPasswordRule {
    open var evaluation: ((String) -> Bool)? = nil

    /// Initialize with a Block.
    public convenience init(evaluation: @escaping (String) -> Bool) {
        self.init()
        self.evaluation = evaluation
    }

    /// Evaluate password. Return false if it is passed and true if failed.
    open func evaluate(_ password: String) -> Bool {
        guard let evaluation = evaluation else {
            return false
        }

        return evaluation(password)
    }

    /// Error description.
    /// Localization Key - "NAVAJO_BLOCK_ERROR"
    open var localizedErrorDescription: String {
        return NSLocalizedString("NAVAJO_BLOCK_ERROR", tableName: nil, bundle: Bundle.main, value: "Must not satisfy precondition", comment: "Navajo - Block rule")
    }
}
