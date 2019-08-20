//
//  ViewController.swift
//  On The Map
//
//  Created by Glenn Cole on 8/14/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpTextView: UITextView!
    
    let segueIdentifierSuccessfulLogin = "completeLogin"
    

    // MARK: - Code begins
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextFields()
        configureSignUpTextView()
    }
    
    private func configureTextFields() {
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        let emailPlaceholder = "Email"
        let passwordPlaceholder = "Password"
        
        let attributedEmailPlaceholder = NSMutableAttributedString(string: emailPlaceholder,
                                                                   attributes: textAttributes)
        emailTextField.attributedPlaceholder = attributedEmailPlaceholder
        
        let attributedPasswordPlaceholder = NSMutableAttributedString( string: passwordPlaceholder,
                                                                       attributes: textAttributes )
        passwordTextField.attributedPlaceholder = attributedPasswordPlaceholder
    }
    
    private func configureSignUpTextView() {
        
        let linkText = "Don't have an account? Sign up"
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.link: URL(string: "https://auth.udacity.com/sign-up")!,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0)
        ]
        
        let attributedLinkText = NSMutableAttributedString( string: linkText,
                                                            attributes: linkAttributes )
        signUpTextView.attributedText = attributedLinkText
        signUpTextView.isSelectable = true
        signUpTextView.isEditable = false
        signUpTextView.textAlignment = .center
        signUpTextView.delaysContentTouches = false
    }

    // MARK: - Process login attempt
    
    @IBAction func loginButtonTapped( _ sender: UIButton ) {
        
        guard let username = emailTextField.text,
            let password = passwordTextField.text
            else { return }
        
        ParseClient.createSession(username: username, password: password, completion: handleLoginResult(success:error:))
    }
    
    private func handleLoginResult( success: Bool, error: Error? ) {
        
        if !success {
            print( "login failed: \(error!)" )
            return
        }
        
        ParseClient.getUserInfo(userId: ParseClient.Auth.key, completion: handleGetUserInfoResult(success:error:))
    }
    
    private func handleGetUserInfoResult( success: Bool, error: Error? ) {
        
        if !success {
            print( "user info failed: \(error!)" )
            return
        }
        
        print( "userinfo = ", ParseClient.studentInfo! )
        self.performSegue( withIdentifier: segueIdentifierSuccessfulLogin, sender: nil )
    }
}

