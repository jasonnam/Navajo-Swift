//
// ViewController.swift
//
// Copyright (c) 2015-2017 Jason Nam (http://www.jasonnam.com)
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

final class ViewController: UIViewController {

    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var strengthLabel: UILabel!
    @IBOutlet private weak var validationLabel: UILabel!

    private var validator = PasswordValidator.standard

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordField.becomeFirstResponder()
    }

    @IBAction func passwordUpdated(_ sender: UITextField) {
        validatePassword()
    }

    @IBAction func changeValidator(_ sender: UISwitch) {
        if sender.isOn {
            let lengthRule = LengthRule(min: 2, max: 4)
            let emailRegularExpression = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: [])
            let emailFilteringRule = RegularExpressionRule(regularExpression: emailRegularExpression)
            validator = PasswordValidator(rules: [lengthRule, emailFilteringRule])
        } else {
            validator = PasswordValidator.standard
        }
        validatePassword()
    }

    private func validatePassword() {
        let password = passwordField.text ?? ""
        let strength = Navajo.strength(ofPassword: password)

        strengthLabel.text = Navajo.localizedString(forStrength: strength)

        if let failingRules = validator.validate(password) {
            validationLabel.textColor = .red
            validationLabel.text = failingRules.map { return $0.localizedErrorDescription }.joined(separator: "\n")
        } else {
            validationLabel.textColor = .green
            validationLabel.text = "Valid"
        }
    }
}
