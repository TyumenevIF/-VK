//
//  Photo.swift
//  VK
//
//  Created by Ilyas Tyumenev on 10/08/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit
import RealmSwift

final class Photo: Object, Decodable {
    @objc dynamic var friendId = 0
    @objc dynamic var imageUrl = ""
    var likeCount: Int = 0
    
    override class func primaryKey() -> String {
        return "imageUrl"
    }
    
    // MARK: - Coding Keys    
    enum CodingKeys: String, CodingKey {
        case photo = "photo_604"
        case likes
        case count
    }
    
    // MARK: - Decodable
    convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imageUrl = try container.decode(String.self, forKey: .photo)
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .likes) {
            self.likeCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
    }
}
