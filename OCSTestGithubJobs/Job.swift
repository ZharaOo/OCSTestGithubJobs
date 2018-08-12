//
//  Job.swift
//  OCSTestGithubJobs
//
//  Created by Ivan Babkin on 12.08.2018.
//  Copyright © 2018 Ivan Babkin. All rights reserved.
//

import UIKit

class Job: NSObject {
    
    var id: String
    var createdAt: String
    var title: String
    var location: String
    var type: String
    var jDescription: String
    var howToApply: String
    var company: String
    var companyURL: URL?
    var companyLogoURL: URL?
    var githubURL: URL?
    var logoImage: UIImage?
    
    var attributedDescription: NSAttributedString? {
        var companyURLHTML: String?
        if let companyUrl = self.companyURL {
            companyURLHTML = "<a href=\"\(companyUrl)\">Our company page</a>"
        }
        
        let cD = """
        <h2>Description</h2>
        \(jDescription)
        \n
        <h2>How to apply</h2>
        \(howToApply)
        \n
        <h2>Links</h2>
        \(companyURLHTML ?? "")
        \n
        <br><a href=\"\(githubURL!)\">View job at github</a>
        """
        
        return try? NSAttributedString(data: cD.data(using: .unicode)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    }
    
    init(id: String, createdAt: String, title: String, location: String, type: String, jDescription: String, howToApply: String, company: String, companyURL: URL?, companyLogoURL: URL?, githubURL: URL?) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.location = location
        self.type = type
        self.jDescription = jDescription
        self.howToApply = howToApply
        self.company = company
        self.companyURL = companyURL
        self.companyLogoURL = companyLogoURL
        self.githubURL = githubURL
    }
    
    convenience init?(dictionary: [String: Any]) {
        if  let id = dictionary["id"] as? String,
            let createdAt = dictionary["created_at"] as? String,
            let title = dictionary["title"] as? String,
            let location = dictionary["location"] as? String,
            let type = dictionary["type"] as? String,
            let jDescription = dictionary["description"] as? String,
            let howToApply = dictionary["how_to_apply"] as? String,
            let company = dictionary["company"] as? String,
            let githubUrlStr = dictionary["url"] as? String {
            
            self.init(id: id,
                      createdAt: createdAt,
                      title: title,
                      location: location,
                      type: type,
                      jDescription: jDescription,
                      howToApply: howToApply,
                      company: company,
                      companyURL: nil,
                      companyLogoURL: nil,
                      githubURL: URL(string: githubUrlStr))
            
            if let companyURLStr = dictionary["company_url"] as? String {
                self.companyURL = URL(string: companyURLStr)
            }
            
            if let companyLogoURLStr = dictionary["company_logo"] as? String {
                self.companyLogoURL = URL(string: companyLogoURLStr)
            }
        }
        else {
            return nil
        }
    }
    
}
