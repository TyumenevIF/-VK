//
//  NewsItem.swift
//  VK
//
//  Created by Ilyas Tyumenev on 10/09/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import UIKit

final class NewsItem: Decodable {    
    var sourceId: Int
    var date: Date
    
    var commentsCount: Int = 0
    var likesCount: Int = 0
    var repostsCount: Int = 0
    var viewsCount: Int = 0
    
    var type: NewsItemInfoType
    var avatar: URL?
    var author: String?
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case sourceId = "source_id"
        case date
        
        case comments
        case likes
        case reposts
        case views
        
        case type
        case count
        case text
    }
    
    // MARK: - Decodable    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.sourceId = try container.decode(Int.self, forKey: .sourceId)
        
        let timeInterval = try container.decode(Int.self, forKey: .date)
        self.date = Date(timeIntervalSince1970: Double(timeInterval))
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .comments) {
            self.commentsCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .likes) {
            self.likesCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .reposts) {
            self.repostsCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .views) {
            self.viewsCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
        
        let typeString = try container.decode(String.self, forKey: .type)
        if typeString == "post" {
            type = .post(try PostNewsItem(from: decoder))
        } else {
            type = .photo(try PhotoNewsItem(from: decoder))
        }
    }
}

// MARK: - NewsItemType & NewsItemInfoType
enum NewsItemType: String {
    case post
    case photo    
}

enum NewsItemInfoType {
    case post(PostNewsItem)
    case photo(PhotoNewsItem)
}

// MARK: - PostNewsItem
final class PostNewsItem: Decodable {
    var text: String
    
    var commentsCount: Int = 0
    var likesCount: Int = 0
    var repostsCount: Int = 0
    var viewsCount: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case text
        
        case comments
        case likes
        case reposts
        case views
        case count
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .comments) {
            self.commentsCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .likes) {
            self.likesCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .reposts) {
            self.repostsCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
        
        if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .views) {
            self.viewsCount = try nestedContainer.decode(Int.self, forKey: .count)
        }
    }
}

// MARK: - PhotoNewsItem
final class PhotoNewsItem: Decodable {
    var photos: [Photo]
    
    private enum CodingKeys: String, CodingKey {
        case photos
        case items
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let photosContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .photos)
        self.photos = (try photosContainer.decode([Photo].self, forKey: .items))
    }
    
    struct Photo: Decodable {
        var photo: URL
        var height: Int
        var width: Int
        
        var commentsCount: Int = 0
        var likesCount: Int = 0
        var repostsCount: Int = 0
        var viewsCount: Int = 0
        
        var aspectRatio: CGFloat {
            return CGFloat(height) / CGFloat(width)
        }
        
        enum CodingKeys: String, CodingKey {
            case photo = "photo_807"
            case height
            case width
            
            case comments
            case likes
            case reposts
            case views
            case count
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.photo = try container.decode(URL.self, forKey: .photo)
            self.height = try container.decode(Int.self, forKey: .height)
            self.width = try container.decode(Int.self, forKey: .width)
            
            if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .likes) {
                self.likesCount = try nestedContainer.decode(Int.self, forKey: .count)
            }
            
            if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .reposts) {
                self.repostsCount = try nestedContainer.decode(Int.self, forKey: .count)
            }
            
            if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .comments) {
                self.commentsCount = try nestedContainer.decode(Int.self, forKey: .count)
            }
        }
    }    
}
