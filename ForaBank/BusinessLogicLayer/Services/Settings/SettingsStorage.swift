//
//  SettingsStorage.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class SettingsStorage: ISettingsStorage {

    public static let shared = SettingsStorage()
    private let userDefaults = UserDefaults.standard

    public func isFirstLaunch() -> Bool {
        return userDefaults.isFirstLaunch()
    }

    public func setFirstLaunch() {
        userDefaults.setFirstLaunch()
    }

    public func allowedBiometricSignIn() -> Bool {
        return userDefaults.allowedBiometricSignIn()
    }

    public func setAllowedBiometricSignIn(allowed: Bool) {
        userDefaults.setAllowedBiometricSignIn(allowed: allowed)
    }

    public func setIsSetPasscode(_ isSet: Bool) {
        userDefaults.setIsSetPasscode(isSet)
    }
    public func isSetPasscode() -> Bool {
        return userDefaults.isSetPasscode()
    }

    public func update(with registrationSettings: RegistrationSettings) {
        setIsSetPasscode(registrationSettings.allowPasscode)
        setAllowedBiometricSignIn(allowed: registrationSettings.allowBiometric)
    }
    
    public func invalidateUserSettings() {
        userDefaults.invalidateUserSettings()
    }
}
