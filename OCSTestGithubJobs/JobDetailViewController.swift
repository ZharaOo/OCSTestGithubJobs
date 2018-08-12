//
//  ViewController.swift
//  OCSTestGithubJobs
//
//  Created by Ivan Babkin on 12.08.2018.
//  Copyright © 2018 Ivan Babkin. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    

    // MARK: - properties
    
    var job: Job?
    
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        display(job: job!)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = contentView.frame.size
    }


    // MARK: - setup displaying
    
    func display(job: Job) {
        titleLabel.text = job.title
        companyLabel.text = "\(job.company) (\(job.location))"
        
        setLogo(with: job.companyLogoURL)
        
        DispatchQueue.global().async {
            let jad = job.attributedDescription
            
            DispatchQueue.main.async {
                self.descriptionTextView.attributedText = jad
                self.view.layoutSubviews()
            }
        }
    }
    
    func setLogo(with url: URL?) {
        if let url = url {
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

