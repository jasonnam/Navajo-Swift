//
// Navajo.swift
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

import Foundation

/// Strength of password. There are five levels divided by entropy value.
/// The entropy value is evaluated by infromation entropy theory.
public enum NJOPasswordStrength {
    /// Entropy value is smaller than 28
    case VeryWeak
    /// Entropy value is between 28 and 35
    case Weak
    /// Entropy value is between 36 and 59
    case Reasonable
    /// Entropy value is between 60 and 127
    case Strong
    /// Entropy value is larger than 127
    case VeryStrong
}

/// Navajo validates strength of passwords.
public class Navajo: NSObject {

    /**
        Gets strength of a password.
        - Parameter password: Password string to be calculated
        - Returns: Level of strength in NJOPasswordStrength
    */
    public class func strengthOfPassword(password: String) -> NJOPasswordStrength {
        return NJOPasswordStrengthForEntropy(NJOEntropyForString(password))
    }

    /// Converts NJOPasswordStrength to localized string.
    public class func localizedStringForPasswordStrength(strength: NJOPasswordStrength) -> String {
        switch strength {
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

    private class func NJOEntropyForString(string: String) -> Float {
        if string.characters.count == 0 {
            return 0.0
        }

        var sizeOfCharacterSet: Float = 0

        (string as NSString).enumerateSubstringsInRange(NSMakeRange(0, string.characters.count), options: NSStringEnumerationOptions.ByComposedCharacterSequences) { ( substring, substringRange, enclosingRange, stop) -> () in
            let char = (substring! as NSString).characterAtIndex(0)

            if NSCharacterSet.lowercaseLetterCharacterSet().characterIsMember(char) {
                sizeOfCharacterSet += 26
            }

            if NSCharacterSet.uppercaseLetterCharacterSet().characterIsMember(char) {
                sizeOfCharacterSet += 26
            }

            if NSCharacterSet.decimalDigitCharacterSet().characterIsMember(char) {
                sizeOfCharacterSet += 10
            }

            if NSCharacterSet.symbolCharacterSet().characterIsMember(char) {
                sizeOfCharacterSet += 10
            }

            if NSCharacterSet.punctuationCharacterSet().characterIsMember(char) {
                sizeOfCharacterSet += 20
            }

            if NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(char) {
                sizeOfCharacterSet += 1
            }

            if NSCharacterSet.nonBaseCharacterSet().characterIsMember(char) {
                sizeOfCharacterSet += 32 + 128
            }
        }

        return log2f(sizeOfCharacterSet) * Float(string.characters.count)
    }

    private class func NJOPasswordStrengthForEntropy(entropy: Float) -> NJOPasswordStrength {
        if entropy < 28 {
            return .VeryWeak
        } else if entropy < 36 {
            return .Weak
        } else if entropy < 60 {
            return .Reasonable
        } else if entropy < 128 {
            return .Strong
        } else {
            return .VeryStrong
        }
    }
}
