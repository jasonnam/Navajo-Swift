//
//  NJOPasswordValidator.swift
//  Navajo
//
//  Created by Jason Nam on 2015. 10. 9..
//  Copyright © 2015년 Jason Nam. All rights reserved.
//

import Foundation

public class NJOPasswordValidator: NSObject
{
    private var _rules: [NJOPasswordRule]! = nil
    
    public convenience init(rules: [NJOPasswordRule])
    {
        self.init()
        _rules = rules
    }
    
    public class func standardValidator() -> NJOPasswordValidator
    {
        return NJOPasswordValidator(rules: [NJOLengthRule(min: 6, max: 24)])
    }
    
    public class func standardLengthRule() -> NJOLengthRule
    {
        return NJOLengthRule(min: 6, max: 24)
    }
    
    public func validatePassword(password: String) -> [NJOPasswordRule]?
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