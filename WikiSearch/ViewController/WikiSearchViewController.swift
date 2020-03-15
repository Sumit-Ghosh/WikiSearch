//
//  ViewController.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 13/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import UIKit
import SafariServices

class WikiSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private let apiClient = APIClient()
    
    private var prefetchOffset: Int = 0
    
    // Boolean to avoid multiple prefecting calls with same offset
    private var prefetchingInProgess: Bool = false
    
    private var searchTimer: Timer?
    private let noResultLabel = UILabel()
    
    private var searchResults = [Page]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.searchVCTitle
        
        setUpSearchController()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe to keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = Constants.searchPlaceholder
        searchController.searchBar.backgroundImage = UIImage()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
    
    private func setUpTableView() {
        tableView.prefetchDataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        setupNoResultsView()
    }
    
    private func setupNoResultsView() {
        let containerView = UIView()
        tableView.backgroundView = containerView
        containerView.addSubview(noResultLabel)
        
        noResultLabel.textColor = .systemGray
        noResultLabel.numberOfLines = 0
        noResultLabel.text = Constants.searchMessage
        noResultLabel.textAlignment = .center
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noResultLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            noResultLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),
            noResultLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
       
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            tableView.setBottomInsetForKeyboard(to: keyboardHeight)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        tableView.setBottomInsetForKeyboard(to: 0.0)
    }
}


extension WikiSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as? WikiTableViewCell else { return UITableViewCell() }
        
        cell.cellTitleLabel.text = searchResults[indexPath.row].title
        cell.cellDescriptionLabel.text = searchResults[indexPath.row].terms?.description.first
        if let url = searchResults[indexPath.row].thumbnail?.source {
            cell.cellImageView.setImage(with: url)
        }

        return cell
    }
}

extension WikiSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pageID = searchResults[indexPath.row].pageid
        
        apiClient.fetchPageURL(pageid: pageID) { [weak self] pageURL, error in
            if case .failure = error { return }
            
            guard let pageURL = pageURL else {
                return
            }
            
            if let url = URL.init(string: pageURL) {
                let safariViewController = SFSafariViewController(url: url)
                self?.present(safariViewController, animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension WikiSearchViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            
            // Check for the last indexpath after which data should be fetched
            if (indexPath.row == (prefetchOffset + 10) - 1 && !prefetchingInProgess) {
                guard let textToSearch = searchController.searchBar.text, !textToSearch.isEmpty else {
                    return
                }
                
                prefetchOffset += 10
                prefetchingInProgess = true
                apiClient.fetchSearchResult(searchText: textToSearch, gpsOffset: prefetchOffset + 1, completionHandler: { [weak self] results, error in
                    
                    self?.prefetchingInProgess = false
                    if case .failure = error { return }
                    guard  let results = results, !results.isEmpty else { return }
                    self?.searchResults.append(contentsOf: results)
                })
                break
            }
        }
    }
}

extension WikiSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            searchResults.removeAll()
            noResultLabel.text = Constants.searchMessage
            return
        }
        
        // Invalidate and restart timer
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: Constants.timeDelayInSearch, repeats: false, block: { (timer) in
            self.fetchResults(for: searchText)
        })
    }
    
    func fetchResults(for keyWord: String) {
        
        prefetchOffset = 0
        apiClient.fetchSearchResult(searchText: keyWord, gpsOffset: prefetchOffset, completionHandler: {
            [weak self] results, error in
            self?.searchResults.removeAll()
            if case .failure = error {
                self?.noResultLabel.text = Constants.errorMessage
                return
            }
            
            guard let results = results, !results.isEmpty else {
                self?.noResultLabel.text = Constants.noResultFoundMessage
                return
            }
            
            self?.searchResults = results
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults.removeAll()
        noResultLabel.text = Constants.searchMessage
    }
}
