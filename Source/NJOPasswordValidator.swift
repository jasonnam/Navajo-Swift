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

public class NJOPasswordValidator: NSObject {
    private var _rules: [NJOPasswordRule]! = nil

    public convenience init(rules: [NJOPasswordRule]) {
        self.init()
        _rules = rules
    }

    public class func standardValidator() -> NJOPasswordValidator {
        return NJOPasswordValidator(rules: [NJOLengthRule(min: 6, max: 24)])
    }

    public class func standardLengthRule() -> NJOLengthRule {
        return NJOLengthRule(min: 6, max: 24)
    }

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
