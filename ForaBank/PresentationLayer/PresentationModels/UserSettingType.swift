//
//  UserSettingType.swift
//  ForaBank
//
//  Created by Бойко Владимир on 05.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

enum UserSettingType {
    case changePassword
    case changePasscode
    case isPasscodeSetted(() -> Bool)
    case allowedBiometricSignIn(() -> Bool)

    public static func isPasscodeSettedDefault() -> UserSettingType {
        return UserSettingType.isPasscodeSetted { () -> Bool in
            return SettingsStorage.shared.isSetPasscode()
        }
    }

    public static func allowedBiometricSignInDefault() -> UserSettingType {
        return UserSettingType.allowedBiometricSignIn { () -> Bool in
            return SettingsStorage.shared.allowedBiometricSignIn()
        }
    }
}
