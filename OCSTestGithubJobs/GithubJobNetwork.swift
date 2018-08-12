//
//  GithubJobNetwork.swift
//  OCSTestGithubJobs
//
//  Created by Ivan Babkin on 12.08.2018.
//  Copyright © 2018 Ivan Babkin. All rights reserved.
//

import UIKit

class GithubJobNetwork: NSObject {
    
    // MARK: - Constants
    
    private let Host = "https://jobs.github.com/positions.json?"
    
    
    // MARK: - Public properties
    
    var session = URLSession(configuration: .default)
    
    
    // MARK: - Singletone
    
    static let sharedInstance = GithubJobNetwork()
    private override init() {}
    
    
    // MARK: - Main load method
    
    @discardableResult private func load(url: URL, completion: @escaping (Data?, Error?) -> ()) -> URLSessionDataTask {
        let dataTask = session.dataTask(with: url) { (data, urlResponse, error) in
            var responseError: Error?
            var responseData: Data?
            
            if let error = error {
                responseError = error
            }
            else {
                if let data = data, let urlResponse = urlResponse as? HTTPURLResponse, urlResponse.statusCode == 200 {
                    responseData = data
                }
                else if let urlResponse = urlResponse as? HTTPURLResponse, urlResponse.statusCode != 200 {
                    responseError = GithubJobNetworkError.HTTPResponseError(urlResponse.statusCode)
                }
            }
            
            completion(responseData, responseError)
        }
        
        dataTask.resume()
        return dataTask
    }
    
    
    //MARK: - Public Methods For Loading
    
    func loadJobs(by searchQuery: String, page: Int, completion: @escaping ([Job]?, Error?) -> ()) {
        let urlString = "\(Host)&search=\(searchQuery)&page=\(page)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
        let url = URL(string: urlString!)
        
        load(url: url!) { (data, error) in
            var responseError: Error?
            var jobsResponse: [Job]?
            
            if let data = data {
                do {
                    jobsResponse = try self.jobArrayDataProcessing(data)
                }
                catch {
                    responseError = error
                }
            }
            else {
                responseError = error
            }
            
            completion(jobsResponse, responseError)
        }
    }
    
    func loadLogo(url: URL, completion: @escaping (UIImage?, Error?) -> ()) {
        load(url: url) { (data, error) in
            if let data = data {
                completion(UIImage(data: data), nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    
    //MARK: - DataProcessing
    
    private func jobArrayDataProcessing(_ data: Data) throws -> [Job] {
        var response: [Any]?
        var jobs = [Job]()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        }
        catch {
            throw GithubJobNetworkError.JSONSerializationError
        }
        
        if let response = response as? [[String: Any]] {
            for jobDictionary in response {
                if let job = Job(dictionary: jobDictionary) {
                    jobs.append(job)
                }
            }
        }
        else {
            throw GithubJobNetworkError.InvalidResultArray
        }
        
        if jobs.count > 0 {
            return jobs
        }
        else {
            throw GithubJobNetworkError.EmptyPageResultError
        }
    }
    
    
}
