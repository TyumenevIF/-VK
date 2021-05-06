//
//  Friend.swift
//  VK
//
//  Created by Ilyas Tyumenev on 05/08/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import RealmSwift

final class Friend: Object, Decodable {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var imageUrl: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case photo = "photo_50"
    }
    
    // MARK: - Decodable    
    convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        let firstName = try container.decode(String.self, forKey: .firstName)
        let lastName = try container.decode(String.self, forKey: .lastName)
        self.name = firstName + " " + lastName
        self.imageUrl = try container.decode(String.self, forKey: .photo)
    }
}
