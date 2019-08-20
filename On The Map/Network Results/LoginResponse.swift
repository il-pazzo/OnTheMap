//
//  LoginResponse.swift
//  On The Map
//
//  Created by Glenn Cole on 8/19/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import Foundation

struct LoginResponse: Codable
{
    let account: Account
    let session: Session

    struct Account: Codable {
        let registered: Bool
        let key: String
    }
    struct Session: Codable {
        let id: String
        let expiration: String
    }
    
}
