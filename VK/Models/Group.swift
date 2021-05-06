//
//  Group.swift
//  VK
//
//  Created by Ilyas Tyumenev on 23/06/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import RealmSwift

final class Group: Object, Decodable {
    @objc dynamic var name = ""
    @objc dynamic var imageUrl: String?
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.name == rhs.name
    }
    
    // MARK: - Coding Keys    
    enum CodingKeys: String, CodingKey {
        case name
        case photo = "photo_50"
    }
    
    // MARK: - Decodable    
    convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.imageUrl = try container.decode(String.self, forKey: .photo)
    }
}
