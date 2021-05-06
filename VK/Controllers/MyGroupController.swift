//
//  MyGroupController.swift
//  VK
//
//  Created by Ilyas Tyumenev on 21/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import RealmSwift

class MyGroupController: UITableViewController, UISearchBarDelegate {
    lazy var service = VKGroupsService()
    lazy var realm = try! Realm()
    lazy var firebase = FirebaseService()
    lazy var photoService = PhotoService(container: self.tableView)
    
    var notificationToken: NotificationToken?
    var items: Results<Group>!
    var selectedGroups: [Group] = []
    var filteredGroups: [Group] = []
    
    var searchActive: Bool = false {
        didSet {
            if searchActive == false {
                filteredGroups = selectedGroups
            }
            tableView.reloadData()
        }
    }
        
    // MARK: - Outlets
    @IBOutlet weak var searchBarMyGroup: UISearchBar!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarMyGroup.delegate = self
        tableView.tableFooterView = UIView()
        bindTableToRealm()
        loadFromNetwork()
    }
    
    func bindTableToRealm() {
        items = realm.objects(Group.self).sorted(byKeyPath: "name", ascending: true)
      
        notificationToken = items.observe { [weak self] (changes) in
            switch changes {
            case .initial(let items):
                self?.updateListGroups(groups: Array(items))
                self?.tableView.reloadData()

            case let .update(items, _, _, _):
                self?.updateListGroups(groups: Array(items))
                
                if self?.searchActive == true {
                    self?.filterGroups(text: self?.searchBarMyGroup.text)
                }
                
                self?.tableView.reloadData()
                
            case let .error(error):
                print(error)
            }
        }
    }
    
    func loadFromNetwork() {
        service.get()
    }
    
    private func updateListGroups(groups: [Group]) {
        let myGroups = Array(items)
        filteredGroups = myGroups
        selectedGroups = myGroups
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredGroups.count
        }
        return selectedGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroupCell", for: indexPath) as! MyGroupCell
        let group: Group
        
        if searchActive {
            group = filteredGroups[indexPath.row]
        } else {
            group = selectedGroups[indexPath.row]
        }
        
        cell.configure(group: group)        
        cell.myGroupImage.image = photoService.photo(at: indexPath, url: group.imageUrl)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteGroup(selectedGroups[indexPath.row])
        }
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
        filterGroups(text: searchText)
        tableView.reloadData()
    }
    
    private func filterGroups(text: String?) {
        if let text = text, text.isEmpty == false {
            filteredGroups = items.filter { $0.name.lowercased().contains(text.lowercased())
            }
        } else {
            filteredGroups = Array(items)
        }
    }
    
    // MARK: - Navigation
    @IBAction func addGroup(segue: UIStoryboardSegue) {
        guard
            let globalGroupsController = segue.source as? GlobalGroupsController,
            let indexPath = globalGroupsController.tableView.indexPathForSelectedRow
            else { return }
        
        let group = globalGroupsController.globalGroups[indexPath.row]
        guard !selectedGroups.contains(group) else { return }

        do {
              try realm.write {
                  realm.add(group, update: .modified)
              }
          } catch {
              print(error)
          }
        
        firebase.addGroup(title: group.name)
    }
    
    // MARK: - Realm helpers
    private func deleteGroup(_ group: Group) {
        do {
            try realm.write {
                realm.delete(group)
            }
        } catch {
            print(error)
        }
    }    
}
