//
//  SignUpView.swift
//  RemoteHome
//
//  Created by John Forde on 24/11/18.
//  Copyright © 2018 4DWare. All rights reserved.
//

import UIKit
import Stevia

class SignUpView: UIView, ValidatesEmail, ValidatesPassword, ValidatesUserInfoField {

	let cancelButton = UIButton()
	let emailAddressLabel = UILabel()
	let emailAddressField = UITextField()
	let firstNameLabel = UILabel()
	let firstNameField = UITextField()
	let lastNameLabel = UILabel()
	let lastNameField = UITextField()
	let password1Label = UILabel()
	let password1Field = UITextField()
	let password2Label = UILabel()
	let password2Field = UITextField()
	let setupUserButton = UIButton()

	let errorLabel = UILabel()

	weak var delegate: SignUpViewControllerDelegate?

	convenience init() {
		self.init(frame: CGRect.zero)
		render()
	}

	func render() {
		// Here we use Stevia to make our constraints more readable and maintainable.
		sv([cancelButton.style(cancelButtonStyle),
				emailAddressLabel.style(labelStyle),
				emailAddressField.style(emailFieldStyle),
				firstNameLabel.style(labelStyle),
				firstNameField.style(nameFieldStyle),
				lastNameLabel.style(labelStyle),
				lastNameField.style(nameFieldStyle),
				password1Label.style(labelStyle),
				password1Field.style(passwordFieldStyle),
				password2Label.style(labelStyle),
				password2Field.style(passwordFieldStyle),
				setupUserButton.style(buttonStyle),
				errorLabel.style(errorLabelStyle)
				])

		backgroundColor = UIColor.backgroundColor
		emailAddressLabel.text = "Email:"
		firstNameLabel.text = "First Name:"
		lastNameLabel.text = "Last Name:"
		password1Label.text = "Password:"
		password2Label.text = "Confirm:"
		setupUserButton.text("Sign Up")
		setupUserButton.addTarget(self, action: #selector(signUpButtonPressed(_:)), for: .touchUpInside)
		errorLabel.text = ""
		password2Field.returnKeyType = .done
		emailAddressField.becomeFirstResponder()


		layout(20,
					 |-errorLabel-(>=8)-cancelButton-|,
					 4,
					 |-8-emailAddressLabel-(>=10)-emailAddressField-8-|,
					 8,
					 |-8-firstNameLabel-(>=10)-firstNameField-8-|,
					 8,
					 |-8-lastNameLabel-(>=10)-lastNameField-8-|,
					 8,
					 |-8-password1Label-(>=10)-password1Field-8-|,
					 8,
					 |-8-password2Label-(>=10)-password2Field-8-|,
					 8,
					 |-8-setupUserButton-8-|,
					 (>=8))
	}

	private func labelStyle(lbl: UILabel) {
		lbl.height(44)
		lbl.textColor = UIColor.white
		lbl.font = .cellFont
	}

	private func errorLabelStyle(lbl: UILabel) {
		labelStyle(lbl: lbl)
		lbl.height(32)
		lbl.textColor = .red
	}

	private func textFieldStyle(txt: UITextField) {
		txt.borderStyle = .roundedRect
		txt.textColor = UIColor.white
		txt.backgroundColor = UIColor.controlColor
		txt.keyboardAppearance = .dark
		txt.returnKeyType = .next
		txt.height(44)
		txt.width(240)
		txt.font = .detailFont
		txt.delegate = self
	}

	private func emailFieldStyle(txt: UITextField) {
		textFieldStyle(txt: txt)
		txt.autocapitalizationType = .none
		txt.autocorrectionType = .no
		txt.keyboardType = .emailAddress
	}

	private func nameFieldStyle(txt: UITextField) {
		textFieldStyle(txt: txt)
		txt.autocapitalizationType = .words
		txt.keyboardType = .alphabet
	}

	private func passwordFieldStyle(txt: UITextField) {
		textFieldStyle(txt: txt)
		txt.isSecureTextEntry = true
		txt.autocapitalizationType = .none
		txt.autocorrectionType = .no
		txt.keyboardType = .alphabet
	}

	private func buttonStyle(btn: UIButton) {
		btn.backgroundColor = UIColor.controlColor
		btn.tintColor = UIColor.white
		btn.height(44)
		btn.layer.cornerRadius = 8
	}

	@objc func signUpButtonPressed(_ sender: Any) {
		print("Sign Up Button Pressed.")
		if let userInfo = validateFields() {
			errorLabel.text = ""
			delegate?.handleSignUp(userInfo: userInfo)
		}
	}

	private func cancelButtonStyle(btn: UIButton) {
		btn.setTitleColor(.white, for: .normal)
		btn.height(20)
		btn.setTitle("X", for: .normal)
		btn.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
	}

	@objc func cancelButtonPressed(_ sender: Any) {
		print("Cancel Button Pressed.")
		errorLabel.text = ""
		delegate?.handleCancel()
	}

	private func validateFields() -> UserSignUpInfo? {
		guard let email = emailAddressField.text?.trimmingCharacters(in: .whitespaces) else {return nil}
		guard let firstName = firstNameField.text?.trimmingCharacters(in: .whitespaces) else {return nil}
		guard let lastName = lastNameField.text?.trimmingCharacters(in: .whitespaces) else {return nil}
		guard let password1 = password1Field.text?.trimmingCharacters(in: .whitespaces) else {return nil}
		guard let password2 = password2Field.text?.trimmingCharacters(in: .whitespaces) else {return nil}

		guard isEmailValid(email) else {
			errorLabel.text = "Please enter a valid email."
			return nil
		}

		guard isUserInfoFieldValid(firstName) else {
			errorLabel.text = "Please enter a valid first name."
			return nil
		}

		guard isUserInfoFieldValid(lastName) else {
			errorLabel.text = "Please enter a valid last name."
			return nil
		}

		guard isPasswordValid(password1) else {
			errorLabel.text = "Please enter a valid password."
			return nil
		}

		if password1Field.text != password2Field.text {
			errorLabel.text = "Passwords do not match."
			return nil
		}

		let userInfo = UserSignUpInfo(email: email,
																	firstName: firstName,
																	lastName: lastName,
																	password1: password1,
																	password2: password2)
		return userInfo
	}

}

extension SignUpView: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()

		switch textField {
		case emailAddressField:
			firstNameField.becomeFirstResponder()
		case firstNameField:
			lastNameField.becomeFirstResponder()
		case lastNameField:
			password1Field.becomeFirstResponder()
		case password1Field:
			password2Field.becomeFirstResponder()
		case password2Field:
			if let userInfo = validateFields() {
				errorLabel.text = ""
				delegate?.handleSignUp(userInfo: userInfo)
			}
		default:
			fatalError("Text Field Delegate Error. Doesn't handle: \(textField.self)")
		}
		return true
	}
}
