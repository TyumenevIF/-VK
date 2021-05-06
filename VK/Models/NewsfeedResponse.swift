//
//  NewsfeedResponse.swift
//  VK
//
//  Created by Ilyas Tyumenev on 10/09/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import Foundation

struct NewsfeedResponse<T: NewsItem>: Decodable {
    var items: [T]
    var nextFrom: String
    
    // MARK: - Coding Keys    
    enum CodingKeys: String, CodingKey {
        case response
        case items
        case profiles
        case groups
        case nextFrom = "next_from"
    }
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        
        let topContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let itemsContainer = try topContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        self.items = try itemsContainer.decode([T].self, forKey: .items)
        
        let profilesContainer = try topContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        let profiles = try? profilesContainer.decode([Profile].self, forKey: .profiles)
        var profileDict = [Int: Profile]()
        for profile in profiles ?? [] {
            profileDict[profile.id] = profile
        }
        
        let groupsContainer = try topContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        let groups = try? groupsContainer.decode([Group].self, forKey: .groups)
        var groupDict = [Int: Group]()
        for group in groups ?? [] {
            groupDict[group.id] = group
        }
        
        for item in items {
            if item.sourceId > 0, let profile = profileDict[item.sourceId] {
                item.avatar = profile.avatar
                item.author = "\(profile.firstName) \(profile.lastName)"
            } else if item.sourceId < 0, let group = groupDict[-item.sourceId] {
                item.avatar = group.avatar
                item.author = group.name
            }
        }
        
        let nextFromContainer = try topContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        self.nextFrom = try nextFromContainer.decode(String.self, forKey: .nextFrom)
    }
    
    private struct Profile: Decodable {
        let id: Int
        let firstName: String
        let lastName: String
        let avatar: URL
        
        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case lastName = "last_name"
            case avatar = "photo_100"
        }
    }
    
    private struct Group: Decodable {
        let id: Int
        let name: String
        let avatar: URL
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case avatar = "photo_100"
        }
    }    
}
