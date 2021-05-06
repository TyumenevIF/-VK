//
//  MyFriendController.swift
//  VK
//
//  Created by Ilyas Tyumenev on 02/07/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import RealmSwift

class MyFriendController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, LetterPickerDelegate {
    lazy var service = VKFriendsService()
    lazy var realm = try! Realm()
    
    var notificationToken: NotificationToken?
    var items: Results<Friend>!
    
    var filteredFriends: [Friend] = []
    var sections: [String] = []
    
    var searchActive: Bool = false {
        didSet {
            if searchActive == false {
                filteredFriends = Array(items)
                letterPicker.isHidden = false
            } else {
                letterPicker.isHidden = true
            }
            tableView.reloadData()
        }
    }
    
    lazy var photoService = PhotoService(container: self.tableView)
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var letterPicker: LetterPicker!
    @IBOutlet weak var searchBarFriend: UISearchBar!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBarFriend.delegate = self
        letterPicker.delegate = self
        
        bindTableToRealm()
        loadFromNetwork()
    }
    
    private func bindTableToRealm() {
        items = realm.objects(Friend.self).sorted(byKeyPath: "name", ascending: true)
        
        notificationToken = items.observe(on: DispatchQueue.main) { [weak self] (changes) in
            switch changes {
            case .initial(let items):
                self?.updateListFriends(friends: Array(items))
                self?.tableView.reloadData()
                
            case let .update(items, _, _, _):
                self?.updateListFriends(friends: Array(items))
                
                if self?.searchActive == true {
                    self?.filterFriends(text: self?.searchBarFriend.text)
                }
                
                self?.tableView.reloadData()
                
            case let .error(error):
                print(error)
            }
        }
    }
    
    func loadFromNetwork () {
        service.get()
    }
    
    private func updateListFriends(friends: [Friend]) {
        filteredFriends = friends
        
        self.sections = Array(
            Set(
                friends.map({
                    String($0.name.prefix(1)).uppercased()
                })
            )
        ).sorted()
        
        self.letterPicker.letters = self.sections
    }
    
    // MARK: - Section
    func itemsInSection(_ section: Int) -> [Friend] {
        let letter = sections[section]
        return items.filter { $0.name.hasPrefix(letter) }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchActive {
            return 1
        }        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchActive {
            return nil
        }
        return sections[section]
    }
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredFriends.count
        }
        return itemsInSection(section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendCell", for: indexPath) as! MyFriendCell
        let friend: Friend
        
        if searchActive {
            friend = filteredFriends[indexPath.row]
        } else {
            friend = itemsInSection(indexPath.section)[indexPath.row]
        }
        
        cell.configure(friend: friend)        
        cell.avatarView.imageView.image = photoService.photo(at: indexPath, url: friend.imageUrl)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        
        UIView.animate(withDuration: 0.2) {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - UISearchBar
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
        filterFriends(text: searchText)
        tableView.reloadData()
    }
    
    private func filterFriends(text: String?) {
        if let text = text, text.isEmpty == false {
            filteredFriends = items.filter { $0.name.lowercased().contains(text.lowercased())
            }
        } else {
            filteredFriends = Array(items)
        }
    }
    
    // MARK: - Letter Picker
    func letterPicked(_ letter: String) {
        if searchActive == false {
            guard let section = sections.firstIndex(of: letter) else { return }
            tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
        } else { return }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            let controller = segue.destination as? FriendPhotoController,
            let indexPath = tableView.indexPathForSelectedRow
        {
            let friend: Friend
            if searchActive {
                friend = filteredFriends[indexPath.row]
            } else {
                friend = itemsInSection(indexPath.section)[indexPath.row]
            }
            controller.title = friend.name
            controller.friendId = friend.id
        }
    }    
}
