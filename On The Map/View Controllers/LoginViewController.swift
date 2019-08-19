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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextFields()
    }
    
    private func configureTextFields() {
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white
//            ,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35.0)
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

    @IBAction func loginButtonTapped( _ sender: UIButton ) {
        
        self.performSegue( withIdentifier: "completeLogin", sender: nil )
    }
}

