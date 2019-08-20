//
//  LoginCredentials.swift
//  On The Map
//
//  Created by Glenn Cole on 8/19/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import Foundation

struct LoginCredentials: Codable
{
    let udacity: [String : String]
}

extension LoginCredentials
{
    init( username: String, password: String ) {
        let dict = [ "username": username, "password": password ]
        self.udacity = dict
    }
}
