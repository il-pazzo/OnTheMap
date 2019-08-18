//
//  StudentLocationsLoader.swift
//  On The Map
//
//  Created by Glenn Cole on 8/17/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import Foundation

class StudentLocationsLoader
{
    class func loadStudentLocationsIfEmpty( completion: @escaping (Error?) -> Void ) {
        
        guard StudentLocationsModel.studentLocations.count <= 0 else {
            completion(nil)
            return
        }
        
        ParseClient.getStudentLocations { (studentLocations, error) in
            StudentLocationsModel.studentLocations = self.filterOutBadData( studentLocations )
            completion(error)
        }
    }
    
    private class func filterOutBadData( _ locations: [StudentLocation]) -> [StudentLocation] {
        
        var results = [StudentLocation]()
        var keys = Set<String>()
        
        for loc in locations {
            guard loc.uniqueKey != "nil" else { continue }
            guard !keys.contains( loc.uniqueKey ) else { continue }
            
            keys.insert( loc.uniqueKey )
            results.append( loc )
        }
        
        return results
    }
}
