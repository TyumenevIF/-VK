//
//  FriendPhotoCell.swift
//  VK
//
//  Created by Ilyas Tyumenev on 21/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

final class FriendPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var friendPhoto: UIImageView!
//    @IBOutlet weak var likesButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        friendPhoto?.image = nil
    }
    
}
