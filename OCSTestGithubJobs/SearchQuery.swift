//
//  SearchQuery.swift
//  OCSTestGithubJobs
//
//  Created by Ivan Babkin on 13.08.2018.
//  Copyright © 2018 Ivan Babkin. All rights reserved.
//

import UIKit

enum State: Int {
    case NonePagesLoaded
    case Searching
    case AllPagesLoaded
}

class SearchQuery: NSObject {
    
    private var observation: NSKeyValueObservation?
    
    var result = [Job]()
    var page = -1
    @objc dynamic var query: String? = ""
    var state: State = .NonePagesLoaded
    
    override init() {
        super.init()
        self.observation = self.observe(\.query, changeHandler: { (searchQuery, change) in
            self.result.removeAll()
            self.page = -1
            self.state = .NonePagesLoaded
        })
    }
    
    deinit {
        observation?.invalidate()
    }
    
}
