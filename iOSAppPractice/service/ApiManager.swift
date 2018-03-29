//
//  ApiManager.swift
//  iOSAppPractice
//
//  Created by Carter on 2018/3/29.
//  Copyright © 2018年 Carter. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }

class ApiManager {
    
    public typealias completeClosureType = ( _ success: Bool, _ response: AnyObject?)->Void
    
    let session: URLSessionProtocol!
    
    init(session: URLSessionProtocol = URLSession.shared ) {
        self.session = session
    }
    
    public func fetchSpotList( offset: Int, callback: @escaping completeClosureType ) {
        
        let queryString = self.generateQueryString(with: [
            "offset": "\(offset)",            
            "rid" : "bf073841-c734-49bf-a97f-3757a6013812",
            "scope" : APIConfig.scope,
            ])
        
        let url = URL(string: String(format:"%@?limit=%@%@", APIConfig.queryURL, APIConfig.limit, queryString))!
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse? , error: Error?) in
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    callback(true, json as AnyObject)
                }else {
                    callback( false , json as AnyObject)
                }
                
            }else {
                callback( false, error?.localizedDescription as AnyObject )
            }
        }
        
        task.resume()
    }
}

fileprivate extension ApiManager {
    
    fileprivate func generateQueryString(with parameter: [String: String]? ) -> String{
        
        var queryString: String = ""
        
        if let parameter = parameter {
            parameter.forEach { (key, value) in
                queryString.append( String( format: "&%@=%@", key, value ))
            }
        }
        
        return queryString
    }
    
}
