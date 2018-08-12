//
//  GithubJobNetworkError.swift
//  OCSTestGithubJobs
//
//  Created by Ivan Babkin on 12.08.2018.
//  Copyright © 2018 Ivan Babkin. All rights reserved.
//

import UIKit

extension Error {
    var description: String {
        if let err = self as? GithubJobNetworkError {
            switch err {
            case .HTTPResponseError(let code):
                return "HTTP Response Error code \(code)"
            default:
                return self.localizedDescription
            }
        }
        
        return self.localizedDescription
    }
    
    var code: Int { return (self as NSError).code  }
}

enum GithubJobNetworkError: Error {
    case InvalidResultArray
    case JSONSerializationError
    case ResponceUnknownError
    case HTTPResponseError(Int)
    case LoadingImageError
    case EmptyPageResultError
    
    static func ==(e1: GithubJobNetworkError, e2: GithubJobNetworkError) -> Bool {
        return e1.code == e2.code
    }
}
