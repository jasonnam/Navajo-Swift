//
// NJOPasswordValidator.swift
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

/// NJOPasswordValidator validates passwords with custom rules.
open class NJOPasswordValidator: NSObject {
    open var rules: [NJOPasswordRule] = []

    /// Initialize NJOPasswordValidator with an array of NJOPasswordRule.
    ///
    /// - parameter rules: Password rule(s)
    ///
    /// - returns: Password validator
    public convenience init(rules: [NJOPasswordRule]) {
        self.init()
        self.rules = rules
    }

    /// NJOPasswordValidator object which checks if the length of password is between 6 and 24.
    open class var standardValidator: NJOPasswordValidator {
        return NJOPasswordValidator(rules: [standardLengthRule])
    }

    /// Length rule having minimum of 6 and maximum of 24.
    open class var standardLengthRule: NJOLengthRule {
        return NJOLengthRule(min: 6, max: 24)
    }

    /// Executes validation with a password and returns failing rules.
    ///
    /// - parameter password: Password string to be validated
    ///
    /// - returns: Failing rules. nil if all of the rules are passed.
    open func validate(_ password: String) -> [NJOPasswordRule]? {
        var failingRules: [NJOPasswordRule] = []

        for rule in rules {
            if rule.evaluate(password) {
                failingRules.insert(rule, at: failingRules.count)
            }
        }

        if failingRules.count > 0 {
            return failingRules
        } else {
            return nil
        }
    }
}
