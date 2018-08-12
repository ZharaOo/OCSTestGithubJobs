//
//  JobsTableViewCell.swift
//  OCSTestGithubJobs
//
//  Created by Ivan Babkin on 12.08.2018.
//  Copyright © 2018 Ivan Babkin. All rights reserved.
//

import UIKit

class JobsTableViewCell: UITableViewCell {
    
    static let Height: CGFloat = 100.0

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    func setupCell(with job: Job) {
        titleLabel.text = job.title
        cityLabel.text = job.location
        
        if let url = job.companyLogoURL {
            let network = GithubJobNetwork.sharedInstance
            network.loadLogo(url: url) { (image, error) in
                DispatchQueue.main.async {
                    if let image = image {
                        self.logoImageView.image = image
                    }
                    else {
                        self.logoImageView.backgroundColor = UIColor.lightGray
                    }
                }
            }
        }
    }

}
