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
        static let isSetNonDisplayBlockProducts = "isSetNonDisplayBlockProducts"
    }

    public func isFirstLaunch() -> Bool {
        return !bool(forKey: Constants.firstLaunchKey)
    }

    public func setFirstLaunch() {
        set(true, forKey: Constants.firstLaunchKey)
        synchronize()
    }

    public func allowedBiometricSignIn() -> Bool {
        return bool(forKey: Constants.allowedBiometricSignInKey)
    }

    public func setAllowedBiometricSignIn(allowed: Bool) {
        set(allowed, forKey: Constants.allowedBiometricSignInKey)
        synchronize()
    }
    func isSetNonDisplayBlockProducts(_ allowed: Bool) -> Bool{
        set(allowed, forKey: Constants.isSetNonDisplayBlockProducts)
        synchronize()
        return (value(forKey: Constants.isSetNonDisplayBlockProducts) != nil)

    }
    

    public func setIsSetPasscode(_ needs: Bool) {
        set(needs, forKey: Constants.isSetPasscodeKey)
        synchronize()
    }

    public func isSetPasscode() -> Bool {
        return bool(forKey: Constants.isSetPasscodeKey)
    }

    public func invalidateUserSettings() {
        removeObject(forKey: Constants.isSetPasscodeKey)
        removeObject(forKey: Constants.allowedBiometricSignInKey)
        synchronize()
    }
}
