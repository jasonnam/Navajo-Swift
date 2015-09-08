//
//  ViewController.swift
//  Navajo
//
//  Created by Jason Nam on 2015. 8. 28..
//  Copyright (c) 2015년 Jason Nam. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var passwordField: UITextField! = nil
    @IBOutlet weak var strengthLabel: UILabel! = nil
    @IBOutlet weak var validationLabel: UILabel! = nil
    
    private var validator: NJOPasswordValidator! = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        passwordField.becomeFirstResponder()
        validator = NJOPasswordValidator.standardValidator()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func passwordChanged(sender: UITextField)
    {
        checkPassword()
    }
    
    @IBAction func optionChanged(sender: UISwitch)
    {
        if sender.on
        {
            var lengthRule = NJOLengthRule(min: 2, max: 4)
            var emailFilteringRule = NJORegularExpressionRule(regularExpression: NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .allZeros, error: nil)!)
            
            validator = NJOPasswordValidator(rules: [lengthRule, emailFilteringRule])
        }
        else
        {
            validator = NJOPasswordValidator.standardValidator()
        }
        
        checkPassword()
    }
    
    private func checkPassword()
    {
        strengthLabel.text = Navajo.localizedStringForPasswordStrength(Navajo.strengthOfPassword(passwordField.text))
        
        var failingRules = validator.validatePassword(passwordField.text)
        
        if failingRules == nil
        {
            validationLabel.textColor = UIColor.greenColor()
            validationLabel.text = "Valid"
        }
        else
        {
            var errorMessage = ""
            
            for var i = 0; i < failingRules!.count; i++
            {
                if i > 1
                {
                    errorMessage += ("\n" + failingRules![i].localizedErrorDescription())
                }
                else
                {
                    errorMessage += failingRules![i].localizedErrorDescription()
                }
            }
            
            validationLabel.textColor = UIColor.redColor()
            validationLabel.text = errorMessage
        }
    }
}