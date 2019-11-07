//
//  UserDefaultsExtensions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

extension UserDefaults: ISettingsStorage {

    private struct Constants {
        static let firstLaunchKey = "isFirstLaunch"
        static let isSetPasscodeKey = "isSetPasscode"
        static let allowedBiometricSignInKey = "allowedBiometricSignIn"
    }

    public func isFirstLaunch() -> Bool {
        return !bool(forKey: Constants.firstLaunchKey)
    }

    public func setFirstLaunch() {
        set(true, forKey: Constants.firstLaunchKey)
    }

    public func allowedBiometricSignIn() -> Bool {
        return bool(forKey: Constants.allowedBiometricSignInKey)
    }

    public func setAllowedBiometricSignIn(allowed: Bool) {
        set(allowed, forKey: Constants.allowedBiometricSignInKey)
    }

    public func setIsSetPasscode(_ needs: Bool) {
        set(needs, forKey: Constants.isSetPasscodeKey)
    }

    public func isSetPasscode() -> Bool {
        return bool(forKey: Constants.isSetPasscodeKey)
    }

    public func invalidateSettings() {
        removeObject(forKey: Constants.firstLaunchKey)
        removeObject(forKey: Constants.isSetPasscodeKey)
        removeObject(forKey: Constants.allowedBiometricSignInKey)
        synchronize()
    }
}
