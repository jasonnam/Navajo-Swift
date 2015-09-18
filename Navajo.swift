//
// SwiftyNavajo.swift
//
// Copyright (c) 2015 Jason Nam (http://www.jasonnam.com)
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

import UIKit

// MARK: Password Strength

enum NJOPasswordStrength
{
    case VeryWeak
    case Weak
    case Reasonable
    case Strong
    case VeryStrong
}

protocol NJOPasswordRule
{
    func evaluateWithString(string: String) -> Bool
    
    func localizedErrorDescription() -> String
}

enum NJORequiredCharacterRulePreset
{
    case LowercaseCharacter
    case UppercaseCharacter
    case DecimalDigitCharacter
    case SymbolCharacter
}

class Navajo: NSObject
{
    class func strengthOfPassword(password: String) -> NJOPasswordStrength
    {
        return NJOPasswordStrengthForEntropy(NJOEntropyForString(password))
    }
    
    class func localizedStringForPasswordStrength(strength: NJOPasswordStrength) -> String
    {
        switch strength
        {
        case .VeryWeak:
            return NSLocalizedString("NAVAJO_VERY_WEAK", tableName: nil, bundle: NSBundle.mainBundle(), value: "Very Weak", comment: "Navajo - Very weak")
        case .Weak:
            return NSLocalizedString("NAVAJO_WEAK", tableName: nil, bundle: NSBundle.mainBundle(), value: "Weak", comment: "Navajo - Weak")
        case .Reasonable:
            return NSLocalizedString("NAVAJO_REASONABLE", tableName: nil, bundle: NSBundle.mainBundle(), value: "Reasonable", comment: "Navajo - Reasonable")
        case .Strong:
            return NSLocalizedString("NAVAJO_STRONG", tableName: nil, bundle: NSBundle.mainBundle(), value: "Strong", comment: "Navajo - Strong")
        case .VeryStrong:
            return NSLocalizedString("NAVAJO_VERY_STRONG", tableName: nil, bundle: NSBundle.mainBundle(), value: "Very Strong", comment: "Navajo - Very Strong")
        }
    }
    
    private class func NJOEntropyForString(string: String) -> Float
    {
        if string.characters.count == 0
        {
            return 0.0
        }

        var sizeOfCharacterSet: Float = 0
        
        (string as NSString).enumerateSubstringsInRange(NSMakeRange(0, string.characters.count), options: NSStringEnumerationOptions.ByComposedCharacterSequences) { ( substring, substringRange, enclosingRange, stop) -> () in
            
            let char = (substring! as NSString).characterAtIndex(0)
            
            if NSCharacterSet.lowercaseLetterCharacterSet().characterIsMember(char)
            {
                sizeOfCharacterSet += 26
            }

            if NSCharacterSet.uppercaseLetterCharacterSet().characterIsMember(char)
            {
                sizeOfCharacterSet += 26
            }
            
            if NSCharacterSet.decimalDigitCharacterSet().characterIsMember(char)
            {
                sizeOfCharacterSet += 10
            }
            
            if NSCharacterSet.symbolCharacterSet().characterIsMember(char)
            {
                sizeOfCharacterSet += 10
            }
            
            if NSCharacterSet.punctuationCharacterSet().characterIsMember(char)
            {
                sizeOfCharacterSet += 20
            }
            
            if NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(char)
            {
                sizeOfCharacterSet += 1
            }
            
            if NSCharacterSet.nonBaseCharacterSet().characterIsMember(char)
            {
                sizeOfCharacterSet += 32 + 128
            }
        }
        
        return log2f(sizeOfCharacterSet) * Float(string.characters.count)
    }
    
    private class func NJOPasswordStrengthForEntropy(entropy: Float) -> NJOPasswordStrength
    {
        if entropy < 28
        {
            return .VeryWeak
        }
        else if entropy < 36
        {
            return .Weak
        }
        else if entropy < 60
        {
            return .Reasonable
        }
        else if entropy < 128
        {
            return .Strong
        }
        else
        {
            return .VeryStrong
        }
    }
}

// MARK: Password Validation

class NJOPasswordValidator: NSObject
{
    private var _rules: [NJOPasswordRule]! = nil
    
    convenience init(rules: [NJOPasswordRule])
    {
        self.init()
        _rules = rules
    }
    
    class func standardValidator() -> NJOPasswordValidator
    {
        return NJOPasswordValidator(rules: [NJOLengthRule(min: 6, max: 24)])
    }
    
    class func standardLengthRule() -> NJOLengthRule
    {
        return NJOLengthRule(min: 6, max: 24)
    }
    
    func validatePassword(password: String) -> [NJOPasswordRule]?
    {
        var failingRules: [NJOPasswordRule] = []
        
        for rule in _rules
        {
            if rule.evaluateWithString(password)
            {
                failingRules.insert(rule, atIndex: failingRules.count)
            }
        }
        
        if failingRules.count == 0
        {
            return nil
        }
        else if failingRules.count > 0
        {
            return failingRules
        }
        else
        {
            return nil
        }
    }
}

class NJOAllowedCharacterRule: NSObject, NJOPasswordRule
{
    private var disallowedCharacters: NSCharacterSet! = nil
    
    convenience init(characterSet: NSCharacterSet)
    {
        self.init()
        disallowedCharacters = characterSet.invertedSet
    }
    
    func evaluateWithString(string: String) -> Bool
    {
        if disallowedCharacters == nil
        {
            return false
        }
        
        return (string as NSString).rangeOfCharacterFromSet(disallowedCharacters).location != NSNotFound
    }
    
    func localizedErrorDescription() -> String
    {
        return NSLocalizedString("NAVAJO_ALLOWED_CHARACTER_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must not include disallowed character", comment: "Navajo - Allowed character rule")
    }
}

class NJORequiredCharacterRule: NSObject, NJOPasswordRule
{
    private var _preset: NJORequiredCharacterRulePreset! = nil
    private var requiredCharacterSet: NSCharacterSet! = nil
    
    convenience init(preset: NJORequiredCharacterRulePreset)
    {
        self.init()
        
        _preset = preset
        
        switch preset
        {
        case .LowercaseCharacter:
            requiredCharacterSet = NSCharacterSet.lowercaseLetterCharacterSet()
        case .UppercaseCharacter:
            requiredCharacterSet = NSCharacterSet.uppercaseLetterCharacterSet()
        case .DecimalDigitCharacter:
            requiredCharacterSet = NSCharacterSet.decimalDigitCharacterSet()
        case .SymbolCharacter:
            let symbolCharacterSet = NSMutableCharacterSet.symbolCharacterSet()
            symbolCharacterSet.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
            requiredCharacterSet = symbolCharacterSet
        }
    }
    
    convenience init(characterSet: NSCharacterSet)
    {
        self.init()
        requiredCharacterSet = characterSet
    }
    
    func evaluateWithString(string: String) -> Bool
    {
        if requiredCharacterSet == nil
        {
            return false
        }
        
        return (string as NSString).rangeOfCharacterFromSet(requiredCharacterSet).location == NSNotFound
    }
    
    func localizedErrorDescription() -> String
    {
        if let preset = _preset
        {
            switch preset
            {
            case .LowercaseCharacter:
                return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_LOWERCASE_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must include lowercase characters", comment: "Navajo - Required lowercase character rule")
            case .UppercaseCharacter:
                return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_UPPERCASE_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must include uppercase characters", comment: "Navajo - Required uppercase character rule")
            case .DecimalDigitCharacter:
                return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_DECIMAL_DIGIT_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must include decimal digit characters", comment: "Navajo - Required decimal digit character rule")
            case .SymbolCharacter:
                return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_SYMBOL_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must include symbol characters", comment: "Navajo - Required symbol character rule")
            }
        }
        else
        {
            return NSLocalizedString("NAVAJO_REQUIRED_CHARACTER_REQUIRED_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must include required characters", comment: "Navajo - Required character rule")
        }
    }
}

class NJODictionaryWordRule: NSObject, NJOPasswordRule
{
    private var nonLowercaseCharacterSet = NSCharacterSet.lowercaseLetterCharacterSet().invertedSet
    
    func evaluateWithString(string: String) -> Bool
    {
        return UIReferenceLibraryViewController.dictionaryHasDefinitionForTerm(string.lowercaseString.stringByTrimmingCharactersInSet(nonLowercaseCharacterSet))
    }
    
    func localizedErrorDescription() -> String
    {
        return NSLocalizedString("NAVAJO_DICTIONARYWORD_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must not be dictionary word", comment: "Navajo - Dictionary word rule")
    }
}

class NJOLengthRule: NSObject, NJOPasswordRule
{
    private var _range: NSRange! = nil
    
    convenience init(min: Int, max: Int)
    {
        self.init()
        _range = NSMakeRange(min, max - min + 1)
    }
    
    func evaluateWithString(string: String) -> Bool
    {
        if _range == nil
        {
            return false
        }
        
        return !NSLocationInRange(string.characters.count, _range)
    }
    
    func localizedErrorDescription() -> String
    {
        return NSLocalizedString("NAVAJO_LENGTH_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must be within range ", comment: "Navajo - Length rule") + NSStringFromRange(_range)
    }
}

class NJOPredicateRule: NSObject, NJOPasswordRule
{
    private var _predicate: NSPredicate! = nil
    
    convenience init(predicate: NSPredicate)
    {
        self.init()
        _predicate = predicate
    }
    
    func evaluateWithString(string: String) -> Bool
    {
        if _predicate == nil
        {
            return false
        }
        
        return _predicate.evaluateWithObject(string)
    }
    
    func localizedErrorDescription() -> String
    {
        return NSLocalizedString("NAVAJO_PREDICATE_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must not match predicate", comment: "Navajo - Predicate rule")
    }
}

class NJORegularExpressionRule: NSObject, NJOPasswordRule
{
    private var _regularExpression: NSRegularExpression! = nil
    
    convenience init(regularExpression: NSRegularExpression)
    {
        self.init()
        _regularExpression = regularExpression
    }
    
    func evaluateWithString(string: String) -> Bool
    {
        if _regularExpression == nil
        {
            return false
        }
        
        return _regularExpression.numberOfMatchesInString(string, options: [], range: NSMakeRange(0, string.characters.count)) > 0
    }
    
    func localizedErrorDescription() -> String
    {
        return NSLocalizedString("NAVAJO_REGEX_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must not match regular expression", comment: "Navajo - Regex rule")
    }
}

class NJOBlockRule: NSObject, NJOPasswordRule
{
    private var _evaluation: (String -> Bool)! = nil
    
    convenience init(evaluation: String -> Bool)
    {
        self.init()
        _evaluation = evaluation
    }
    
    func evaluateWithString(string: String) -> Bool
    {
        if _evaluation == nil
        {
            return false
        }
        
        return _evaluation(string)
    }
    
    func localizedErrorDescription() -> String
    {
        return NSLocalizedString("NAVAJO_BLOCK_ERROR", tableName: nil, bundle: NSBundle.mainBundle(), value: "Must not satisfy precondition", comment: "Navajo - Block rule")
    }
}