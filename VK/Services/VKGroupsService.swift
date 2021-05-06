//
//  VKGroupsService.swift
//  VK
//
//  Created by Ilyas Tyumenev on 23/09/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit

final class VKGroupsService {
    
    // MARK: - get    
    func get() {
        firstly {
            load()
        }.then { data in
            self.parse(data)
        }.done { groups in
            try self.save(groups)
        }.catch { error in
            print(error)
        }
    }
    
    // MARK: - load
    func load() -> Promise<Data> {
        guard let url = VKService.createUrl(for: .groupsGet) else {
            return Promise(error: PMKError.cancelled)
            
        }
        
        return Promise<Data> { (resolver) in
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    resolver.reject(error)
                } else {
                    resolver.fulfill(data ?? Data())
                }
            }.resume()
        }
    }
    
    // MARK: - parse
    func parse(_ data: Data) -> Promise<[Group]> {
        return Promise<[Group]> { (resolver) in
            do {
                let response = try JSONDecoder().decode(VKResponse<Group>.self, from: data)
                resolver.fulfill(response.items)
            } catch {
                resolver.reject(error)
            }
        }
    }
    
    // MARK: - save
    func save(_ groups: [Group]) throws {
        let realm = try Realm()
        
        try realm.write {
            realm.add(groups, update: .modified)
        }
    }
}
