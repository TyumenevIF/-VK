//
//  VKService.swift
//  VK
//
//  Created by Ilyas Tyumenev on 30/07/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import Foundation
import RealmSwift

final class VKService {    
    let newsViewController = NewsViewController()
    let session = Session.instance
    
    enum Method {
        case friendsGet
        case photosGetAll(id: Int)
        case groupsGet
        case groupsSearch(text: String)
        case newsfeedGet(_ type: NewsItemType?, startTime: String?, startFrom: String?)
        
        var path: String {
            switch self {
            case .friendsGet:
                return "/method/friends.get"
            case .photosGetAll:
                return "/method/photos.getAll"
            case .groupsGet:
                return "/method/groups.get"
            case .groupsSearch:
                return "/method/groups.search"
            case .newsfeedGet:
                return "/method/newsfeed.get"
            }
        }
        
        var parameters: [String: String] {
            switch self {
            case .friendsGet:
                return ["fields": "photo_50"]
            case let .photosGetAll(id):
                var m = ["owner_id": "\(id)"]
                m["extended"] = "1"
                return m
            case .groupsGet:
                return ["extended": "1"]
            case let .groupsSearch(text):
                return ["q": text]
            case let .newsfeedGet(type, startTime, startFrom):
                var m = ["filters": type?.rawValue ?? "\(NewsItemType.post.rawValue),\(NewsItemType.photo.rawValue)"]
                
                if let startTime = startTime {
                    m["start_time"] = startTime
                }
                
                if let startFrom = startFrom {
                    m["start_from"] = startFrom
                }
                return m
            }
        }
    }
    
    // MARK: - Public request
    func request<T: Decodable>(_ method: Method, _ type: T.Type, needToCache: Bool = true, completion: (([T]) -> Void)? = nil) {
        request(method) { (data) in
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(VKResponse<T>.self, from: data)
                
                if let objects = response.items as? [Object], needToCache {
                    self.saveToRealm(objects, method: method)
                }
                completion?(response.items)
            } catch {
                print("VKService error: \(error.localizedDescription)")
                completion?([])
            }
        }
    }    
    
    // MARK: - createUrl
    static func createUrl(for method: Method) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.vk.com"
        components.path = method.path
        
        let queryItems = [
            URLQueryItem(name: "access_token", value: Session.instance.token),
            URLQueryItem(name: "v", value: "5.131"),
            URLQueryItem(name: "count", value: "10")
        ]
        
        let methodQueryItems = method.parameters.map { URLQueryItem(name: $0, value: $1) }
        components.queryItems = queryItems + methodQueryItems
        return components.url
    }
    
    // MARK: - request
    private func request(_ method: Method, completion: @escaping ((Data?) -> Void)) {
        guard let url = Self.createUrl(for: method) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        print("\nURL метода \(method):", url)
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("VKService error: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
        
        task.resume()
    }
    
    // MARK: - getNewsfeed
    func getNewsfeed(
        startTime: TimeInterval? = nil,
        startFrom: String? = nil,
        _ newsfeedType: NewsItemType?,
        completion: (([NewsItem], String
        ) -> Void)? = nil) {
        
        DispatchQueue.global(qos: .utility).async {
            self.request(.newsfeedGet(newsfeedType, startTime: startTime.flatMap { "\($0)" }, startFrom: startFrom)) { (data) in
                guard let data = data else { return }
                
                do {
                    let response = try JSONDecoder().decode(NewsfeedResponse<NewsItem>.self, from: data)
                    completion?(response.items, response.nextFrom)
                    print(#function)
                } catch {
                    print("VKService error: \(error.localizedDescription)")
                    completion?([], "")
                }
            }
        }
    }
    
    // MARK: - saveToRealm    
    private func saveToRealm<T: Object>(_ objects: [T], method: Method) {
        do {
            let realm = try Realm()
            
            try realm.write {
                if case .photosGetAll(let id) = method {
                    objects.map { $0 as? Photo }.forEach { $0?.friendId = id }
                }
                
                realm.add(objects, update: .modified)
            }
        } catch {
            print(error)
        }
    }    
}
