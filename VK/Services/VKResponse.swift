//
//  VKResponse.swift
//  VK
//
//  Created by Ilyas Tyumenev on 05/08/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import Foundation

struct VKResponse<T: Decodable>: Decodable {
    var count: Int
    var items: [T]
    
    // MARK: - Coding Keys    
    enum CodingKeys: String, CodingKey {
        case response
        case count
        case items
    }
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        let topContainer = try decoder.container(keyedBy: CodingKeys.self)
        let container = try topContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        
        self.count = try container.decode(Int.self, forKey: .count)
        self.items = try container.decode([T].self, forKey: .items)
    }
}
