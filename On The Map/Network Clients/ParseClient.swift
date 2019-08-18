//
//  ParseClient.swift
//  On The Map
//
//  Created by Glenn Cole on 8/17/19.
//  Copyright © 2019 Glenn Cole. All rights reserved.
//

import Foundation

class ParseClient
{
    static let kLimit = "limit"
    static let kSkip = "skip"
    static let kOrder = "order"
    
    enum Endpoints
    {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case getLocations(parmMap: [String:String])
        
        var stringValue: String {
            switch self {
            case .getLocations(let parmMap):
                return "\(Endpoints.base)/StudentLocation\(parmMapToString(parmMap))"
            }
        }
        
        func parmMapToString( _ map: [String:String] ) -> String {
            guard map.count > 0 else {
                return ""
            }
            return "?" + map.map { (k,v) -> String in
                "\(k)=\(v)"
                }.joined(separator: "&")
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getStudentLocations(completion: @escaping ([StudentLocation], Error?) -> Void) {
        
//        let parmMap = [ kLimit:"10000", kOrder:"-updatedAt" ]
        let parmMap = [ kLimit:"200", kOrder:"-updatedAt" ]
        taskForGETRequest(url: Endpoints.getLocations(parmMap: parmMap).url, responseType: StudentLocations.self) {
            (response, error) in
            
            guard let response = response else {
                completion( [], nil )
                return
            }
            
            print("Retrieved \(response.results.count) results!" )
            completion(response.results, nil)
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(
        url: URL,
        responseType: ResponseType.Type,
        completion: @escaping (ResponseType?, Error?) -> Void ) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType, from: data)
                DispatchQueue.main.async { completion(responseObject, nil) }
            }
            catch {
                let savedError = error
//                do {
//                    let tmdbResponse = try decoder.decode( TMDBResponse.self, from: data )
//                    DispatchQueue.main.async { completion(nil, tmdbResponse) }
//                }
//                catch {
                    DispatchQueue.main.async { completion(nil, savedError) }
//                }
            }
        }
        task.resume()
        
        return task
    }
}
