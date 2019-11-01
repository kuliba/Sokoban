//
//  SettingsStorage.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class SettingsStorage: ISettingsStorage {

    static let shared = SettingsStorage()
    let userDefaults = UserDefaults.standard

    func isFirstLaunch() -> Bool {
        return userDefaults.isFirstLaunch()
    }

    func setFirstLaunch() {
        userDefaults.setFirstLaunch()
    }

    func setNeedSetPasscode(_ needs: Bool) {
        userDefaults.setNeedSetPasscode(needs)
    }
    func isNeedSetPasscode() -> Bool {
        return userDefaults.isNeedSetPasscode()
    }
}
