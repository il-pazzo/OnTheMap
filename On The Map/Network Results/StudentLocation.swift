//
//  StudentLocation.swift
//  On The Map
//
//  Created by Glenn Cole on 8/17/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import Foundation

struct StudentLocation: Codable
{
    let uniqueKey: String
    let objectId: String
    let createdAt: String
    let updatedAt: String
    
    let firstName: String
    let lastName: String
    let longitude: Double
    let latitude: Double
    let mapString: String
    let mediaURL: String
}

extension StudentLocation
{
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return "?"
        }

        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    var isValidURL: Bool {

        guard let url = URL(string: mediaURL),
            let scheme = url.scheme,
            !scheme.isEmpty,
            ["http", "https"].contains( scheme.lowercased())
        else {
            return false
        }
        return true
    }
}
