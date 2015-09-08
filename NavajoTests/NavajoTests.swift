//
//  NavajoTests.swift
//  NavajoTests
//
//  Created by Jason Nam on 2015. 8. 29..
//  Copyright (c) 2015년 Jason Nam. All rights reserved.
//

import UIKit
import XCTest

class NavajoTests: XCTestCase
{    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAllowedCharacterRule()
    {
        var ruleWithoutInitialCharacterSet = NJOAllowedCharacterRule()
        
        XCTAssert(ruleWithoutInitialCharacterSet.evaluateWithString("PASSWORD") == false, "Allowed character rule not ignored")
        
        
        var ruleWithInitialCharacterSet = NJOAllowedCharacterRule(characterSet: NSCharacterSet(charactersInString: "abc"))
        
        XCTAssert(ruleWithInitialCharacterSet.evaluateWithString("abcd") == true, "Disallowed characters are not filtered out")
        XCTAssert(ruleWithInitialCharacterSet.evaluateWithString("aaa") == false, "Allowed characters are used but failed to pass")
        XCTAssert(ruleWithInitialCharacterSet.evaluateWithString("aabbccaaabbbcccaaaabbbbcccc") == false, "Allowed characters are used but failed to pass")
    }
    
    func testRequiredCharacterRule()
    {
        var ruleWithoutInitialOption = NJORequiredCharacterRule()
        
        XCTAssert(ruleWithoutInitialOption.evaluateWithString("PASSWORD") == false, "Required character rule without initial option not ignored")
        
        
        var ruleWithRequiredCharacters = NJORequiredCharacterRule(characterSet: NSCharacterSet(charactersInString: "!@#ABCabc"))
        
        XCTAssert(ruleWithRequiredCharacters.evaluateWithString("!d@e#fAgBhCabc") == false, "All of the required characters are used but not passed")
        XCTAssert(ruleWithRequiredCharacters.evaluateWithString("!d@e#fAg") == false, "Some of the required characters are used but not passed")
        XCTAssert(ruleWithRequiredCharacters.evaluateWithString("deg$%^") == true, "Required characters are not used but passed")
        
        
        var ruleWithInitialLowercasePreset = NJORequiredCharacterRule(preset: .LowercaseCharacter)
        
        XCTAssert(ruleWithInitialLowercasePreset.evaluateWithString("Abcdef12345!@#") == false, "Some of the characters are lowercase but not passed")
        XCTAssert(ruleWithInitialLowercasePreset.evaluateWithString("ABCDEF12345!@#") == true, "All of them are uppercase but passed")
        
        
        var ruleWithInitialUppercasePreset = NJORequiredCharacterRule(preset: .UppercaseCharacter)
        
        XCTAssert(ruleWithInitialUppercasePreset.evaluateWithString("AbcDef12345!@#") == false, "Some of the characters are uppercase but not passed")
        XCTAssert(ruleWithInitialUppercasePreset.evaluateWithString("abcdef12345!@#") == true, "All of them are lowercase but passed")
        
        
        var ruleWithInitialDecimalDigitPreset = NJORequiredCharacterRule(preset: .DecimalDigitCharacter)
        
        XCTAssert(ruleWithInitialDecimalDigitPreset.evaluateWithString("Abcdef12345!@#") == false, "Some of the characters are decimal digits but not passed")
        XCTAssert(ruleWithInitialDecimalDigitPreset.evaluateWithString("abcdef!@#") == true, "No decimal digits but passed")
        
        
        var ruleWithInitialSymbolPreset = NJORequiredCharacterRule(preset: .SymbolCharacter)
        
        XCTAssert(ruleWithInitialSymbolPreset.evaluateWithString("Abcdef12345!") == false, "Some of the characters are symbols but not passed")
        XCTAssert(ruleWithInitialSymbolPreset.evaluateWithString("abcdef") == true, "No symbols but passed")
    }
    
    func testLengthRule()
    {
        var ruleWithoutInitialRange = NJOLengthRule()
        
        XCTAssert(ruleWithoutInitialRange.evaluateWithString("PASSWORD") == false, "Length rule without initial range but not ignored")
        
        
        var ruleWithInitialRange = NJOLengthRule(min: 6, max: 9)
        
        XCTAssert(ruleWithInitialRange.evaluateWithString("12345") == true, "Password is too short but passed")
        XCTAssert(ruleWithInitialRange.evaluateWithString("123456") == false, "Password is in range but not passed")
        XCTAssert(ruleWithInitialRange.evaluateWithString("123456789") == false, "Password is in range but not passed")
        XCTAssert(ruleWithInitialRange.evaluateWithString("1234567890") == true, "Password is too long but passed")
    }
    
    func testPredicateRule()
    {
        var ruleWithoutInitialPredicate = NJOPredicateRule()
        
        XCTAssert(ruleWithoutInitialPredicate.evaluateWithString("PASSWORD") == false, "Length rule without initial predicate but not ignored")
        
        
        var ruleWithInitialPredicate = NJOPredicateRule(predicate: NSPredicate(format: "SELF BEGINSWITH %@", "PASSWORD"))
        
        XCTAssert(ruleWithInitialPredicate.evaluateWithString("PASSWORDINPUT!") == true, "Password begins with PASSWORD but passed")
        XCTAssert(ruleWithInitialPredicate.evaluateWithString("PASS") == false, "Password doesn't begin with PASSWORD but not passed")
    }
    
    func testRegexRule()
    {
        var ruleWithoutInitialRegex = NJORegularExpressionRule()
        
        XCTAssert(ruleWithoutInitialRegex.evaluateWithString("PASSWORD") == false, "Length rule without initial regex but not ignored")
        
        
        // Email Regex
        var ruleWithInitialRegex = NJORegularExpressionRule(regularExpression: NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .allZeros, error: nil)!)
        
        XCTAssert(ruleWithInitialRegex.evaluateWithString("contact@jasonnam.com") == true, "Password is an email but passed")
        XCTAssert(ruleWithInitialRegex.evaluateWithString("PASSWORD") == false, "Password is not an email but not passed")
    }
    
    func testBlockRule()
    {
        var ruleWithoutInitialBlock = NJOBlockRule()
        
        XCTAssert(ruleWithoutInitialBlock.evaluateWithString("PASSWORD") == false, "Length rule without initial block but not ignored")
        
        
        var ruleWithInitialBlock = NJOBlockRule() { (password: String) in
            
            var emailRegex = NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .allZeros, error: nil)!
            return emailRegex.numberOfMatchesInString(password, options: .allZeros, range: NSMakeRange(0, count(password))) > 0
            
        }
        
        XCTAssert(ruleWithInitialBlock.evaluateWithString("contact@jasonnam.com") == true, "Password is an email but passed")
        XCTAssert(ruleWithInitialBlock.evaluateWithString("PASSWORD") == false, "Password is not an email but not passed")
    }
}