//
//  MyFriendsCell.swift
//  VK
//
//  Created by Ilyas Tyumenev on 21/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

final class MyFriendCell: UITableViewCell {
    
    @IBOutlet weak var myFriendLabel: UILabel!    
    @IBOutlet weak var avatarView: AvatarView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView?.avatarImage = nil
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(tap)
    }
    
    @objc func avatarTapped(_ recognizer: UITapGestureRecognizer) {
        avatarView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
            self.avatarView.transform = .identity
        }, completion: { _ in
            
        })
    }
    
    func configure(friend: Friend) {
        myFriendLabel.text = friend.name
        
    }
}
