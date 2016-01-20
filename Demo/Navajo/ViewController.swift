//
// ViewController.swift
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

class ViewController: UIViewController {
    @IBOutlet weak var passwordField: UITextField! = nil
    @IBOutlet weak var strengthLabel: UILabel! = nil
    @IBOutlet weak var validationLabel: UILabel! = nil
    
    private var validator: NJOPasswordValidator! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.becomeFirstResponder()
        validator = NJOPasswordValidator.standardValidator()
    }
    
    @IBAction func passwordChanged(sender: UITextField) {
        checkPassword()
    }
    
    @IBAction func optionChanged(sender: UISwitch) {
        if sender.on {
            let lengthRule = NJOLengthRule(min: 2, max: 4)
            let emailFilteringRule = NJORegularExpressionRule(regularExpression: try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: []))
            
            validator = NJOPasswordValidator(rules: [lengthRule, emailFilteringRule])
        } else {
            validator = NJOPasswordValidator.standardValidator()
        }
        
        checkPassword()
    }
    
    private func checkPassword() {
        strengthLabel.text = Navajo.localizedStringForPasswordStrength(Navajo.strengthOfPassword(passwordField.text!))
        
        var failingRules = validator.validatePassword(passwordField.text!)
        
        if failingRules == nil {
            validationLabel.textColor = UIColor.greenColor()
            validationLabel.text = "Valid"
        } else {
            var errorMessage = ""
            
            for var i = 0; i < failingRules!.count; i++ {
                if i > 1 {
                    errorMessage += ("\n" + failingRules![i].localizedErrorDescription())
                } else {
                    errorMessage += failingRules![i].localizedErrorDescription()
                }
            }
            
            validationLabel.textColor = UIColor.redColor()
            validationLabel.text = errorMessage
        }
    }
}
