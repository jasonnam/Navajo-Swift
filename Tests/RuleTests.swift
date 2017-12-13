//
// RuleTests.swift
//
// Copyright (c) 2015-2017 Jason Nam (http://jasonnam.com)
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

#if os(OSX)
    import CoreServices
#else
    import UIKit
#endif
import XCTest

class RuleTests: XCTestCase {

    func testAllowedCharacterRule() {
        let ruleWithoutInitialCharacterSet = AllowedCharacterRule()

        XCTAssertFalse(ruleWithoutInitialCharacterSet.evaluate("PASSWORD"), "Allowed character rule not ignored")

        let ruleWithInitialCharacterSet = AllowedCharacterRule(allowedCharacters: CharacterSet(charactersIn: "abc"))

        XCTAssertTrue(ruleWithInitialCharacterSet.evaluate("abcd"), "Disallowed characters are not filtered out")
        XCTAssertFalse(ruleWithInitialCharacterSet.evaluate("aaa"), "Allowed characters are used but failed to pass")
        XCTAssertFalse(ruleWithInitialCharacterSet.evaluate("aabbccaaabbbcccaaaabbbbcccc"), "Allowed characters are used but failed to pass")
    }

    func testRequiredCharacterRule() {
        let ruleWithoutInitialOption = RequiredCharacterRule()

        XCTAssertFalse(ruleWithoutInitialOption.evaluate("PASSWORD"), "Required character rule without initial option not ignored")


        let ruleWithRequiredCharacters = RequiredCharacterRule(requiredCharacterSet: CharacterSet(charactersIn: "!@#ABCabc"))

        XCTAssertFalse(ruleWithRequiredCharacters.evaluate("!d@e#fAgBhCabc"), "All of the required characters are used but not passed")
        XCTAssertFalse(ruleWithRequiredCharacters.evaluate("!d@e#fAg"), "Some of the required characters are used but not passed")
        XCTAssertTrue(ruleWithRequiredCharacters.evaluate("deg$%^"), "Required characters are not used but passed")


        let ruleWithInitialLowercasePreset = RequiredCharacterRule(preset: .lowercaseCharacter)

        XCTAssertFalse(ruleWithInitialLowercasePreset.evaluate("Abcdef12345!@#"), "Some of the characters are lowercase but not passed")
        XCTAssertTrue(ruleWithInitialLowercasePreset.evaluate("ABCDEF12345!@#"), "All of them are uppercase but passed")


        let ruleWithInitialUppercasePreset = RequiredCharacterRule(preset: .uppercaseCharacter)

        XCTAssertFalse(ruleWithInitialUppercasePreset.evaluate("AbcDef12345!@#"), "Some of the characters are uppercase but not passed")
        XCTAssertTrue(ruleWithInitialUppercasePreset.evaluate("abcdef12345!@#"), "All of them are lowercase but passed")


        let ruleWithInitialDecimalDigitPreset = RequiredCharacterRule(preset: .decimalDigitCharacter)

        XCTAssertFalse(ruleWithInitialDecimalDigitPreset.evaluate("Abcdef12345!@#"), "Some of the characters are decimal digits but not passed")
        XCTAssertTrue(ruleWithInitialDecimalDigitPreset.evaluate("abcdef!@#"), "No decimal digits but passed")


        let ruleWithInitialSymbolPreset = RequiredCharacterRule(preset: .symbolCharacter)

        XCTAssertFalse(ruleWithInitialSymbolPreset.evaluate("Abcdef12345!"), "Some of the characters are symbols but not passed")
        XCTAssertTrue(ruleWithInitialSymbolPreset.evaluate("abcdef"), "No symbols but passed")
    }

    func testLengthRule() {
        let ruleWithoutInitialRange = LengthRule()

        XCTAssertFalse(ruleWithoutInitialRange.evaluate("PASSWORD"), "Length rule without initial range but not ignored")


        let ruleWithInitialRange = LengthRule(min: 6, max: 9)

        XCTAssertTrue(ruleWithInitialRange.evaluate("12345"), "Password is too short but passed")
        XCTAssertFalse(ruleWithInitialRange.evaluate("123456"), "Password is in range but not passed")
        XCTAssertFalse(ruleWithInitialRange.evaluate("123456789"), "Password is in range but not passed")
        XCTAssertTrue(ruleWithInitialRange.evaluate("1234567890"), "Password is too long but passed")
    }

    func testPredicateRule() {
        let ruleWithoutInitialPredicate = PredicateRule()

        XCTAssertFalse(ruleWithoutInitialPredicate.evaluate("PASSWORD"), "Length rule without initial predicate but not ignored")


        let ruleWithInitialPredicate = PredicateRule(predicate: NSPredicate(format: "SELF BEGINSWITH %@", "PASSWORD"))

        XCTAssertTrue(ruleWithInitialPredicate.evaluate("PASSWORDINPUT!"), "Password begins with PASSWORD but passed")
        XCTAssertFalse(ruleWithInitialPredicate.evaluate("PASS"), "Password doesn't begin with PASSWORD but not passed")
    }

    func testRegexRule() {
        let ruleWithoutInitialRegex = RegularExpressionRule()

        XCTAssertFalse(ruleWithoutInitialRegex.evaluate("PASSWORD"), "Length rule without initial regex but not ignored")


        // Email Regex
        let ruleWithInitialRegex = RegularExpressionRule(regularExpression: try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: []))

        XCTAssertTrue(ruleWithInitialRegex.evaluate("contact@jasonnam.com"), "Password is an email but passed")
        XCTAssertFalse(ruleWithInitialRegex.evaluate("PASSWORD"), "Password is not an email but not passed")
    }

    func testBlockRule() {
        let ruleWithoutInitialBlock = BlockRule()

        XCTAssertFalse(ruleWithoutInitialBlock.evaluate("PASSWORD"), "Length rule without initial block but not ignored")


        let ruleWithInitialBlock = BlockRule() { (password: String) in
            let emailRegex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: [])
            return emailRegex.numberOfMatches(in: password, options: [], range: NSMakeRange(0, password.count)) > 0
        }

        XCTAssertTrue(ruleWithInitialBlock.evaluate("contact@jasonnam.com"), "Password is an email but passed")
        XCTAssertFalse(ruleWithInitialBlock.evaluate("PASSWORD"), "Password is not an email but not passed")
    }
}
