//
//  Item.swift
//  RealmPlayground
//
//  Created by Max Gribov on 03.12.2021.
//

import Foundation
import RealmSwift

class Item: Object, Identifiable {
    
    @objc dynamic var id = ""
    @objc dynamic var value = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
