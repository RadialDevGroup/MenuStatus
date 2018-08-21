//
//  SlackService.swift
//  MenuStatus
//
//  Created by Geoffrey Thompson on 7/31/18.
//  Copyright © 2018 Radial Development Group. All rights reserved.
//

import Foundation

class SlackService {
    static let shared = SlackService()
    var token: String?

    typealias JSONDictionary = [String: Any]
    typealias QueryResult = (Profile?, String) -> ()
    
    var profile: Profile?
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?

    var setProfileDataTask: URLSessionDataTask?

    func setProfile(statusText: String, statusEmoji: String, completion: @escaping QueryResult) {
        setProfileDataTask?.cancel()

        let json: [String: Any] = ["profile": ["status_text": statusText, "status_emoji": statusEmoji]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "https://slack.com/api/users.profile.set")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        setProfileDataTask = createDataTask(request: request, completion: completion)
        setProfileDataTask?.resume()
    }
    
    func getProfile(completion: @escaping QueryResult) {
        dataTask?.cancel()
        
        var urlComponents = URLComponents(string: "https://slack.com/api/users.profile.get")!
        urlComponents.query = "token=\(token!)"

        guard let url = urlComponents.url else { return }
        let request = URLRequest(url: url)

        dataTask = createDataTask(request: request, completion: completion)
        dataTask?.resume()
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

        if let statusText = profile["status_text"] as? String,
            let statusEmoji = profile["status_emoji"] as? String {
            self.profile = Profile(statusText: statusText, statusEmoji: statusEmoji)
        }
    }

    func createDataTask(request: URLRequest, completion: @escaping QueryResult) -> URLSessionDataTask {
        return defaultSession.dataTask(with: request) { data, response, error in
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                self.updateProfile(data)

                DispatchQueue.main.async {
                    completion(self.profile, self.errorMessage)
                }
            }
        }
    }

    func setToken(token: String) {
        self.token = token
    }
}
