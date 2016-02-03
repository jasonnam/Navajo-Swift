//
// NJOPasswordValidator.swift
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

/// NJOPasswordValidator validates passwords with custom rules.
public class NJOPasswordValidator: NSObject {
    private var _rules: [NJOPasswordRule]! = nil

    /// Initialize NJOPasswordValidator with an array of NJOPasswordRule.
    public convenience init(rules: [NJOPasswordRule]) {
        self.init()
        _rules = rules
    }

    /// NJOPasswordValidator object which checks if the length of password is between 6 and 24.
    public class func standardValidator() -> NJOPasswordValidator {
        return NJOPasswordValidator(rules: [NJOLengthRule(min: 6, max: 24)])
    }

    /// Length rule having minimum of 6 and maximum of 24.
    public class func standardLengthRule() -> NJOLengthRule {
        return NJOLengthRule(min: 6, max: 24)
    }

    /**
        Executes validation with a password and returns failing rules.
        - Parameter password: Password string to be validated
        - Returns: Failing rules. nil if all of the rules are passed.
    */
    public func validatePassword(password: String) -> [NJOPasswordRule]? {
        var failingRules: [NJOPasswordRule] = []

        for rule in _rules {
            if rule.evaluateWithString(password) {
                failingRules.insert(rule, atIndex: failingRules.count)
            }
        }

        if failingRules.count == 0 {
            return nil
        } else if failingRules.count > 0 {
            return failingRules
        } else {
            return nil
        }
    }
}
