//
// Navajo.swift
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

/// Strength of password. There are five levels divided by entropy value.
/// The entropy value is evaluated by infromation entropy theory.
public enum NJOPasswordStrength {
    /// Entropy value is smaller than 28
    case veryWeak
    /// Entropy value is between 28 and 35
    case weak
    /// Entropy value is between 36 and 59
    case reasonable
    /// Entropy value is between 60 and 127
    case strong
    /// Entropy value is larger than 127
    case veryStrong
}

/// Navajo validates strength of passwords.
open class Navajo: NSObject {

    /**
        Gets strength of a password.
        - Parameter password: Password string to be calculated
        - Returns: Level of strength in NJOPasswordStrength
    */
    open class func strengthOfPassword(_ password: String) -> NJOPasswordStrength {
        return NJOPasswordStrengthForEntropy(NJOEntropyForString(password))
    }

    /// Converts NJOPasswordStrength to localized string.
    open class func localizedStringForPasswordStrength(_ strength: NJOPasswordStrength) -> String {
        switch strength {
        case .veryWeak:
            return NSLocalizedString("NAVAJO_VERY_WEAK", tableName: nil, bundle: Bundle.main, value: "Very Weak", comment: "Navajo - Very weak")
        case .weak:
            return NSLocalizedString("NAVAJO_WEAK", tableName: nil, bundle: Bundle.main, value: "Weak", comment: "Navajo - Weak")
        case .reasonable:
            return NSLocalizedString("NAVAJO_REASONABLE", tableName: nil, bundle: Bundle.main, value: "Reasonable", comment: "Navajo - Reasonable")
        case .strong:
            return NSLocalizedString("NAVAJO_STRONG", tableName: nil, bundle: Bundle.main, value: "Strong", comment: "Navajo - Strong")
        case .veryStrong:
            return NSLocalizedString("NAVAJO_VERY_STRONG", tableName: nil, bundle: Bundle.main, value: "Very Strong", comment: "Navajo - Very Strong")
        }
    }

    fileprivate class func NJOEntropyForString(_ string: String) -> Float {
        if string.characters.count == 0 {
            return 0.0
        }

        var sizeOfCharacterSet: Float = 0

        (string as NSString).enumerateSubstrings(in: NSMakeRange(0, string.characters.count), options: NSString.EnumerationOptions.byComposedCharacterSequences) { ( substring, substringRange, enclosingRange, stop) -> () in
            let char = (substring! as NSString).character(at: 0)

            if CharacterSet.lowercaseLetters.contains(UnicodeScalar(char)!) {
                sizeOfCharacterSet += 26
            }

            if CharacterSet.uppercaseLetters.contains(UnicodeScalar(char)!) {
                sizeOfCharacterSet += 26
            }

            if CharacterSet.decimalDigits.contains(UnicodeScalar(char)!) {
                sizeOfCharacterSet += 10
            }

            if CharacterSet.symbols.contains(UnicodeScalar(char)!) {
                sizeOfCharacterSet += 10
            }

            if CharacterSet.punctuationCharacters.contains(UnicodeScalar(char)!) {
                sizeOfCharacterSet += 20
            }

            if CharacterSet.whitespacesAndNewlines.contains(UnicodeScalar(char)!) {
                sizeOfCharacterSet += 1
            }

            if CharacterSet.nonBaseCharacters.contains(UnicodeScalar(char)!) {
                sizeOfCharacterSet += 32 + 128
            }
        }

        return log2f(sizeOfCharacterSet) * Float(string.characters.count)
    }

    fileprivate class func NJOPasswordStrengthForEntropy(_ entropy: Float) -> NJOPasswordStrength {
        if entropy < 28 {
            return .veryWeak
        } else if entropy < 36 {
            return .weak
        } else if entropy < 60 {
            return .reasonable
        } else if entropy < 128 {
            return .strong
        } else {
            return .veryStrong
        }
    }
}
