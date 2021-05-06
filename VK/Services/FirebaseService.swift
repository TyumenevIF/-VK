//
//  FirebaseService.swift
//  VK
//
//  Created by Ilyas Tyumenev on 28/08/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class FirebaseService {    
    enum Child: String {
        case users
        case groups
        case title
    }
    
    lazy var session = Session.instance
    lazy var database = Database.database()
    
    func logUser() {
        let ref = database.reference()
            .child(Child.users.rawValue)
            .child(session.userId)      
        
        ref.updateChildValues([Child.groups.rawValue: ""])
    }
    
    func addGroup(title: String) {
        let ref = database.reference()
            .child(Child.users.rawValue)
            .child(session.userId)
            .child(Child.groups.rawValue)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let groups: [String] = snapshot.value as? [String] ?? []
            
            if !groups.contains(title) {
                let updateGroups = groups + [title]
                ref.setValue(updateGroups)
            }
        }
    }
}
