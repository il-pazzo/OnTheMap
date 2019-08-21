//
//  OTMCallFailedResponse.swift
//  On The Map
//
//  Created by Glenn Cole on 8/20/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import Foundation

struct OTMCallFailedResponse: Codable
{
    let status: Int
    let error: String
}

extension OTMCallFailedResponse: LocalizedError
{
    var errorDescription: String? {
        return error
    }
}
