//
//  GlobalGroupsController.swift
//  VK
//
//  Created by Ilyas Tyumenev on 21/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

class GlobalGroupsController: UITableViewController, UISearchBarDelegate {
    lazy var service = VKService()
    lazy var photoService = PhotoService(container: self.tableView)
    
    var globalGroups: [Group] = []
    var filteredGlobalGroups: [Group] = []
    
    var searchActive: Bool = false {
        didSet {
            if searchActive == false {
                filteredGlobalGroups = globalGroups
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var searchBarGlobalGroup: UISearchBar!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarGlobalGroup.delegate = self
        tableView.tableFooterView = UIView()        
        tableView?.reloadData()
    }
    
    func groupsSearch(_ text: String) {
        service.request(.groupsSearch(text: text), Group.self, needToCache: false) { [weak self] groups in
            let sortedGroups = groups.sorted { $0.name < $1.name }
            self?.globalGroups = sortedGroups
            self?.filteredGlobalGroups = sortedGroups
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchBarGlobalGroup.becomeFirstResponder()
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredGlobalGroups.count
        }
        return globalGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalGroupsCell", for: indexPath) as! GlobalGroupsCell
        let group: Group
        
        if searchActive {
            group = filteredGlobalGroups[indexPath.row]
        } else {
            group = globalGroups[indexPath.row]
        }
        
        cell.globalGroupLabel.text = group.name
        cell.configure(group: group)        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - SearchBar    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        groupsSearch(searchText)
    }
}
