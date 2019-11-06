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

    func allowedBiometricSignIn() -> Bool {
        return userDefaults.allowedBiometricSignIn()
    }

    func setAllowedBiometricSignIn(allowed: Bool) {
        userDefaults.setAllowedBiometricSignIn(allowed: allowed)
    }

    func setIsSetPasscode(_ needs: Bool) {
        userDefaults.setIsSetPasscode(needs)
    }
    func isSetPasscode() -> Bool {
        return userDefaults.isSetPasscode()
    }
}
