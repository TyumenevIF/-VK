//
//  MyGroupCell.swift
//  VK
//
//  Created by Ilyas Tyumenev on 21/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

final class MyGroupCell: UITableViewCell {
    
    @IBOutlet weak var myGroupLabel: UILabel!    
    @IBOutlet weak var myGroupImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myGroupImage?.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myGroupImage.layer.cornerRadius = myGroupImage.bounds.width / 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        myGroupImage.isUserInteractionEnabled = true
        myGroupImage.addGestureRecognizer(tap)
    }
    
    @objc func avatarTapped(_ recognizer: UITapGestureRecognizer) {
        myGroupImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
            self.myGroupImage.transform = .identity
        }, completion: { _ in
            
        })
    }
    
    func configure(group: Group) {
        myGroupLabel.text = group.name
    }
}
