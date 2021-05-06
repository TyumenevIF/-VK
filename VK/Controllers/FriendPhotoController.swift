//
//  FriendPhotoController.swift
//  VK
//
//  Created by Ilyas Tyumenev on 21/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import RealmSwift

class FriendPhotoController: UICollectionViewController {
    lazy var service = VKService()
    lazy var realm = try! Realm()
    
    var notificationToken: NotificationToken?
    var items: Results<Photo>!
    
    var friendId: Int = 0
    var photos: [Photo] = []
    
    lazy var photoService = PhotoService(container: self.collectionView)
    
    // MARK: - Life cycle    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindCollectionToRealm()
        loadFromNetwork()
    }
    
    private func bindCollectionToRealm() {
        items = realm.objects(Photo.self).filter("friendId == %@", friendId)
        photos = Array(items)
        
        notificationToken = items.observe { [weak self] (changes) in
            switch changes {
            case .initial:
                self?.collectionView.reloadData()
                
            case let .update(_, deletions, insertions, modifications):
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.deleteItems(at: deletions.mapToIndexPaths())
                    self?.collectionView.insertItems(at: insertions.mapToIndexPaths())
                    self?.collectionView.reloadItems(at: modifications.mapToIndexPaths())
                }, completion: nil)
                
            case let .error(error):
                print(error)
            }
        }
    }
    
    func loadFromNetwork () {
        service.request(.photosGetAll(id: friendId), Photo.self)
    }
    
    // MARK: - UICollectionView    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendPhotoCell", for: indexPath) as! FriendPhotoCell
        let photo = items[indexPath.row]        
        cell.friendPhoto.image = photoService.photo(at: indexPath, url: photo.imageUrl)        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let friendPhotoViewController = storyboard.instantiateViewController(identifier: "FriendPhotoViewController")
            as! FriendPhotoViewController
        
        friendPhotoViewController.photos = Array(items)
        friendPhotoViewController.currentIndex = indexPath.row
        navigationController?.pushViewController(friendPhotoViewController, animated: true)
    }
}
