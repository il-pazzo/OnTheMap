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
    
    static var studentInfo: GetUserInfoResponse?
    
    struct Auth
    {
        static var lastObjectId: String?
        static var key = ""
        static var id = ""
    }
    
    enum Endpoints
    {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        // endpoints with "normal" (use-as-is) response
        case getLocations( parmMap: [String:String] )
        case newStudentLocation
        case updateStudentLocation( objectId: String )
        
        // endpoints with "goofy" (strip-off-first-5-chars) response
        case createSession
        case killSession
        case getUserInfo( userId: String )
        
        var stringValue: String {
            switch self {
            case .getLocations(let parmMap):
                return "\(Endpoints.base)/StudentLocation\(parmMapToString(parmMap))"
            case .newStudentLocation:
                return "\(Endpoints.base)/StudentLocation"
            case .updateStudentLocation( let objectId ):
                return "\(Endpoints.base)/StudentLocation/\(objectId)"
                
            case .createSession:
                return "\(Endpoints.base)/session"
            case .killSession:
                return "\(Endpoints.base)/session"
            case .getUserInfo( let userId ):
                return "\(Endpoints.base)/users/\(userId)"
            }
        }
        
        var hasGoofyResponse: Bool {
            switch self {
            case .createSession, .killSession, .getUserInfo:
                return true
            default:
                return false
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
    
    enum MethodType: String
    {
        case PUT = "PUT"
        case POST = "POST"
        case GET = "GET"
        case DELETE = "DELETE"
    }
    
    enum MiscNetworkError: Error
    {
        case invalidMethodType(String)
    }
    
    class func getStudentLocations(completion: @escaping ([StudentLocation], Error?) -> Void) {
        
        let parmMap = [ kLimit:"100", kOrder:"-updatedAt" ]
        let endpoint = Endpoints.getLocations(parmMap: parmMap)
        taskForGETRequest( url: endpoint.url,
                           hasGoofyResponse: endpoint.hasGoofyResponse,
                           responseType: StudentLocations.self) { (response, error) in
            
            guard let response = response else {
                completion( [], error )
                return
            }
            
            completion(response.results, nil)
        }
    }
    
    class func getUserInfo( userId: String, completion: @escaping (Bool, Error?) -> Void ) {
        
        let endpoint = Endpoints.getUserInfo( userId: userId )
        taskForGETRequest( url: endpoint.url,
                           hasGoofyResponse: endpoint.hasGoofyResponse,
                           responseType: GetUserInfoResponse.self
        ) { (response, error) in
            
            guard let response = response else {
                completion( false, error )
                return
            }
            
            studentInfo = response
            completion( true, nil )
        }
    }
    private class func studentLocation( from userInfo: GetUserInfoResponse ) -> StudentLocation {
        
        let loc = StudentLocation( uniqueKey: userInfo.key,
                                   firstName: userInfo.firstName ?? "",
                                   lastName: userInfo.lastName ?? "",
                                   mapString: userInfo.mailingAddress ?? "",
                                   mediaURL: userInfo.mediaUrl ?? "" )
        
        return loc
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(
        url: URL,
        hasGoofyResponse: Bool,
        responseType: ResponseType.Type,
        completion: @escaping (ResponseType?, Error?) -> Void ) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let tweakedData = hasGoofyResponse ? data.subdata(in: 5..<data.count) : data
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(responseType, from: tweakedData)
                DispatchQueue.main.async { completion(responseObject, nil) }
            }
            catch {
                let savedError = error
                print( "data was: ", String(data: tweakedData, encoding: .utf8)! )
                print( "parse GET failed: \(error)")
                do {
                    let otmCallFailedResponse = try decoder.decode( OTMCallFailedResponse.self, from: tweakedData )
                    DispatchQueue.main.async { completion( nil, otmCallFailedResponse ) }
                }
                catch {
                    DispatchQueue.main.async { completion(nil, savedError) }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func addNewStudentLocation( loc: StudentLocation,
                                      completion: @escaping (Bool, Error?) -> Void ) {
        
        let endpoint = Endpoints.newStudentLocation
        taskForPOSTRequest( url: endpoint.url,
                            methodType: MethodType.POST.rawValue,
                            hasGoofyResponse: endpoint.hasGoofyResponse,
                            responseType: ParsePostStudentLocationResponse.self,
                            body: loc ) { (response, error) in
            
            guard let response = response else {
                completion( false, error )
                return
            }
            
            Auth.lastObjectId = response.objectId
            completion( true, nil )
        }
    }
    
    class func updateStudentLocation( loc: StudentLocation,
                                      completion: @escaping (Bool, Error?) -> Void ) {
        
        let endpoint = Endpoints.updateStudentLocation(objectId: loc.objectId)
        
        taskForPOSTRequest( url: endpoint.url,
                            methodType: MethodType.PUT.rawValue,
                            hasGoofyResponse: endpoint.hasGoofyResponse,
                            responseType: ParsePutStudentLocationResponse.self,
                            body: loc ) { (response, error) in
            
            guard let _ = response else {
                completion( false, error )
                return
            }
            
            completion( true, nil )
        }
    }
    
    class func createSession( username: String, password: String, completion: @escaping (Bool, Error?) -> Void ) {
        
        let loginCredentials = LoginCredentials( username: username, password: password )
        let endpoint = Endpoints.createSession
        
        taskForPOSTRequest(url: endpoint.url,
                           methodType: MethodType.POST.rawValue,
                           hasGoofyResponse: endpoint.hasGoofyResponse,
                           responseType: LoginResponse.self,
                           body: loginCredentials ) { (response, error) in
                            
            guard let response = response else {
                var tweakedError = error
                if error is OTMCallFailedResponse {
                    let otmError = error as! OTMCallFailedResponse
                    if otmError.status == 400 {
                        tweakedError = OTMCallFailedResponse(status: otmError.status,
                                                             error: "Username or password is incorrect")
                    }
                }
                completion( false, tweakedError )
                return
            }
            
            Auth.key = response.account.key
            Auth.id = response.session.id
                            
            completion( true, nil )
        }
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(
            url: URL,
            methodType: String,
            hasGoofyResponse: Bool,
            responseType: ResponseType.Type,
            body: RequestType,
            completion: @escaping (ResponseType?, Error?) -> Void ) {
        
        let supportedMethodTypes = ["PUT", "POST"]
        guard supportedMethodTypes.contains( methodType ) else {
            let error = MiscNetworkError.invalidMethodType("Internal error: Expected one of \(supportedMethodTypes); found \(methodType)")
            DispatchQueue.main.async { completion( nil, error ) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = methodType
        request.addValue("application/json", forHTTPHeaderField: "Content-Type" )
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(body)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async { completion( nil, error ) }
                return
            }
            
            let tweakedData = hasGoofyResponse ? data.subdata(in: 5..<data.count) : data
            let decoder = JSONDecoder()
            do {
                let sessionResponse = try decoder.decode(responseType, from: tweakedData)
                DispatchQueue.main.async { completion( sessionResponse, nil ) }
            }
            catch {
                let savedError = error
                print( "data was: ", String(data: tweakedData, encoding: .utf8)! )
                print( "parse POST failed: \(error)")
                do {
                    let otmCallFailedResponse = try decoder.decode( OTMCallFailedResponse.self, from: tweakedData )
                    DispatchQueue.main.async { completion( nil, otmCallFailedResponse ) }
                }
                catch {
                    DispatchQueue.main.async { completion( nil, savedError ) }
                }
            }
        }
        task.resume()
    }
    
    class func killSession( completion: ((Bool, Error?) -> Void)? ) {
        
        let endpoint = Endpoints.killSession
        taskForDELETERequest( url: endpoint.url,
                              hasGoofyResponse: endpoint.hasGoofyResponse
        ) { (data, _, error) in
                            
            guard let _ = data else {
                completion?( false, error )
                return
            }
            
            Auth.key = ""
            Auth.id = ""
            
            completion?( true, nil )
        }
    }
    
    class func taskForDELETERequest(
            url: URL,
            hasGoofyResponse: Bool,
            completion: @escaping (Data?, URLResponse?, Error?) -> Void ) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        for cookie in HTTPCookieStorage.shared.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
                break
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                DispatchQueue.main.async { completion( nil, response, error ) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion( nil, response, error ) }
                return
            }
            
            let tweakedData = hasGoofyResponse ? data.subdata(in: 5..<data.count) : data
            DispatchQueue.main.async { completion( tweakedData, response, nil ) }
        }
        task.resume()
    }
}
