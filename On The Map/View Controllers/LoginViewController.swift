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
    
    let segueIdentifierSuccessfulLogin = "completeLogin"
    

    // MARK: - Code begins
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextFields()
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

