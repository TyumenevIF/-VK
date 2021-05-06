//
//  GlobalGroupsCell.swift
//  VK
//
//  Created by Ilyas Tyumenev on 21/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import Kingfisher

final class GlobalGroupsCell: UITableViewCell {
    
    @IBOutlet weak var globalGroupLabel: UILabel!    
    @IBOutlet weak var globalGroupImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        globalGroupImage.layer.cornerRadius = globalGroupImage.bounds.width / 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        globalGroupImage.isUserInteractionEnabled = true
        globalGroupImage.addGestureRecognizer(tap)
    }
    
    @objc func avatarTapped(_ recognizer: UITapGestureRecognizer) {
        globalGroupImage.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
            self.globalGroupImage.transform = .identity
        }, completion: { _ in
            
        })
    }
    
    func configure(group: Group) {
        globalGroupLabel.text = group.name
        
        if let imageUrl = group.imageUrl, let url = URL(string: imageUrl) {
            let resource = ImageResource(downloadURL: url)
            globalGroupImage.kf.setImage(with: resource)
        }
    }    
    
}
