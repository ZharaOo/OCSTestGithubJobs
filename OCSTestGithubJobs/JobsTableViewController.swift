//
//  JobsTableViewController.swift
//  OCSTestGithubJobs
//
//  Created by Ivan Babkin on 12.08.2018.
//  Copyright © 2018 Ivan Babkin. All rights reserved.
//

import UIKit

class JobsTableViewController: UITableViewController, UISearchBarDelegate {

    // MARK: - Constants
    
    private let JobDetailSegueInentifier = "JobDetailSegue"
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: - Properties
    
    var searchQuery = SearchQuery()
    var githubJobNetwork = GithubJobNetwork.sharedInstance
    
    var noDataLabel: UILabel?
    
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: tableView.bounds.height))
        noDataLabel!.text = "Enter job keyword"
        noDataLabel!.textAlignment = .center
    }
    
    
    // MARK: - Table view data source & delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchQuery.state == .NonePagesLoaded {
            tableView.separatorStyle = .none
            tableView.backgroundView = noDataLabel
        }
        else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        
        return searchQuery.result.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return JobsTableViewCell.Height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! JobsTableViewCell
        
        cell.setupCell(with: searchQuery.result[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && searchQuery.state != .AllPagesLoaded {
            loadNextPage()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: JobDetailSegueInentifier, sender: searchQuery.result[indexPath.row])
    }
    
    
    //MARK: - Table view scroll delegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.endEditing(true)
        
        if let searchText = searchBar.text, searchText.count > 0 {
            searchQuery.query = searchText
            tableView.reloadData()
            
            loadNextPage()
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == JobDetailSegueInentifier {
            let dvc = segue.destination as! JobDetailViewController
            dvc.job = sender as? Job
        }
    }
    
    
    // MARK: - Page loading
    
    func loadNextPage() {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        tableView.tableFooterView = indicator
        tableView.tableFooterView?.isHidden = false
        indicator.startAnimating()
        
        githubJobNetwork.loadJobs(by: searchQuery.query!, page: searchQuery.page + 1) { (searchResults, error) in
            DispatchQueue.main.async {
                indicator.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true
            }
            
            if let searchResults = searchResults {
                self.searchQuery.page += 1
                self.searchQuery.state = .Searching
                
                DispatchQueue.main.async {
                    self.appendDataToTableView(searchResults)
                }
            }
            else {
                if let error = error as? GithubJobNetworkError, error == .EmptyPageResultError, self.searchQuery.state != .NonePagesLoaded {
                    self.searchQuery.state = .AllPagesLoaded
                    return
                }
                
                let message = error?.description ?? "Unknown error"
                
                DispatchQueue.main.async {
                    self.showError(message: message)
                }
            }
        }
    }
    
    func appendDataToTableView( _ searchResults: [Job]) {
        if self.searchQuery.page == 0 {
            self.searchQuery.result = searchResults
            self.tableView.reloadData()
        }
        else {
            self.searchQuery.result.append(contentsOf: searchResults)
            var indexPaths = [IndexPath]()
            
            for i in self.searchQuery.result.count - searchResults.count ... self.searchQuery.result.count - 1 {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            
            self.tableView.insertRows(at: indexPaths, with: .none)
        }
    }
    
    func showError(message: String) {
        if self.searchQuery.state == .NonePagesLoaded {
            self.tableView.backgroundView = self.noDataLabel
        }
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
