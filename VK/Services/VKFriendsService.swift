//
//  VKFriendsService.swift
//  VK
//
//  Created by Ilyas Tyumenev on 19/09/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import Foundation
import RealmSwift

final class VKFriendsService {
    lazy var operationQueue = OperationQueue()
    
    func get() {
        let fetchOperation = FetchOperation()
        let parseOperation = ParseOperation()
        let saveOperation = SaveOperation()
        
        parseOperation.addDependency(fetchOperation)
        saveOperation.addDependency(parseOperation)
        
        let operations = [fetchOperation, parseOperation, saveOperation]
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    // MARK: - Operations
    final class FetchOperation: AsyncOperation {
        var outputData: Data?
        var outputError: Error?
        
        override func main() {
            let method = VKService.Method.friendsGet
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.vk.com"
            components.path = method.path
            
            let queryItems = [
                URLQueryItem(name: "access_token", value: Session.instance.token),
                URLQueryItem(name: "v", value: "5.131")
            ]
            
            let methodQueryItems = method.parameters.map { URLQueryItem(name: $0, value: $1) }
            components.queryItems = queryItems + methodQueryItems
            
            guard let url = components.url else { return }
            print("\nURL метода \(method):", url)
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { [weak self] (data, _, error) in
                self?.outputData = data
                self?.outputError = error
                self?.state = .finished
            }
            
            task.resume()
        }
    }
    
    final class ParseOperation: Operation {
        var outputItems: [Friend]?
        var outputError: Error?
        
        override func main() {
            guard
                let operation = dependencies.first as? FetchOperation,
                let data = operation.outputData
            else { return }
            do {
                let response = try JSONDecoder().decode(VKResponse<Friend>.self, from: data)
                outputItems = response.items
                
            } catch {
                outputError = error
            }
        }
    }
    
    final class SaveOperation: Operation {        
        var outputError: Error?
        
        override func main() {
            guard
                let operation = dependencies.first as? ParseOperation,
                let items = operation.outputItems
            else { return }
            
            do {
                let realm = try Realm()
                
                try realm.write {
                    realm.add(items, update: .modified)
                }
            } catch {
                outputError = error
            }
        }        
    }
}

// MARK: - Async Operation
class AsyncOperation: Operation {
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" +  rawValue.capitalized
        }
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override func start() {
        if isCancelled {
            state = .finished
        } else {
            main()
            state = .executing
        }
    }
    
    override func cancel() {
        super.cancel()
        state = .finished
    }
}
