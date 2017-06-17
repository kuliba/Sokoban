//
//  SPSettings.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 06.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit

class SPSettings: NSObject {
    
    static let shared = SPSettings()
    
    var CurrentLevelCollectionFileName: String {
        set { UserDefaults.standard.setValue(newValue, forKey: "CurrentLevelCollectionFileName") }
        get { return UserDefaults.standard.value(forKey: "CurrentLevelCollectionFileName") as! String }
    }

    var CurrentLevelId: String {
        set { UserDefaults.standard.setValue(newValue, forKey: "CurrentLevelId") }
        get { return UserDefaults.standard.value(forKey: "CurrentLevelId") as! String }
    }

    override init() {
        super.init()
        UserDefaults.standard.register(defaults: ["CurrentLevelCollectionFileName" : "Original"])
        UserDefaults.standard.register(defaults: ["CurrentLevelId" : "Original"])
    }
}
