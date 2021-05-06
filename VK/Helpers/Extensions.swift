//
//  Extensions.swift
//  VK
//
//  Created by Ilyas Tyumenev on 22/08/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element == Int {
    func mapToIndexPaths() -> [IndexPath] {
        return map { IndexPath(row: $0, section: 0) }
    }
}

extension UIView {    
    func makeCircle() {
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true
    }
}

extension UITableView {
    func showEmptyMessage (_ message: String) {
        let label = UILabel(frame: bounds)
        label.text = message
        label.textColor = .gray
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        
        self.backgroundView = label
    }
    
    func hideEmptyMessage() {
        self.backgroundView = nil
    }
}
