//
//  SlackService.swift
//  MenuExample
//
//  Created by Geoffrey Thompson on 7/31/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Foundation

class SlackService {
    let token = "fake-slack-token"
    
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = (Profile?, String) -> ()
    
    var profile: Profile?
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    func getProfile(completion: @escaping QueryResult) {
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: "https://slack.com/api/users.profile.get") {
            urlComponents.query = "token=\(token)"
            
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                
                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
//                    let responseData = String(data: data, encoding: String.Encoding.utf8)
//                    NSLog(responseData!)
                    self.updateProfile(data)
                    
                    DispatchQueue.main.async {
                        completion(self.profile, self.errorMessage)
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    fileprivate func updateProfile(_ data: Data) {
        var response: JSONDictionary!
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let profile = response!["profile"] as? JSONDictionary else {
            errorMessage += "Dictionary does not contain profile\n"
            return
        }
        
        if let profile = profile as? JSONDictionary,
            let statusText = profile["status_text"] as? String {
            self.profile = Profile(statusText: statusText)
        }
    }
}
