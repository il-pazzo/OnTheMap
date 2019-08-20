//
//  GetUserInfoResponse.swift
//  On The Map
//
//  Created by Glenn Cole on 8/19/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import Foundation

struct GetUserInfoResponse: Codable
{
    let key: String
    let lastName: String?
    let firstName: String?
    let websiteUrl: String?
    let linkedInUrl: String?
    let mailingAddress: String?
    
    enum CodingKeys: String, CodingKey
    {
        case key
        case lastName = "last_name"
        case firstName = "first_name"
        case websiteUrl = "website_url"
        case linkedInUrl = "linkedin_url"
        case mailingAddress = "mailing_address"
    }
    
    var mediaUrl: String? {
        if      let websiteUrl = websiteUrl, !websiteUrl.isEmpty { return websiteUrl }
        else if let linkedInUrl = linkedInUrl, !linkedInUrl.isEmpty { return linkedInUrl }
        else { return nil }
    }
}
