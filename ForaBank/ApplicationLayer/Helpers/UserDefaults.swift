//
//  UserDefaults.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

func setAppHasRunForFirst() {
    UserDefaults.standard.set(true, forKey: "hasRunBefore")
    UserDefaults.standard.synchronize()
}

func appHasRunForBefore() -> Bool {
    if UserDefaults.standard.object(forKey: "hasRunBefore") == nil {
        return true
    }
    return false
}
