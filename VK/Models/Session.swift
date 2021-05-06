//
//  Session.swift
//  VK
//
//  Created by Ilyas Tyumenev on 27/07/2020.
//  Copyright © 2020 Ilyas Tyumenev. All rights reserved.
//

import Foundation

final class Session {    
    var token = ""
    var userId = ""
    
    // MARK: - Singleton
    static let instance = Session()
    private init() {}
}
