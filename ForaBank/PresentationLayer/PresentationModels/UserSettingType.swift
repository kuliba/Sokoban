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

    var localizedName: String {
        switch self {
        case .changePassword:
            return NSLocalizedString("Изменть пароль", comment: "")
        case .changePasscode:
            return NSLocalizedString("Изменить 4-х значный код", comment: "")
        case .isPasscodeSetted:
            return NSLocalizedString("4-х значный код", comment: "")
        case .allowedBiometricSignIn:
            return NSLocalizedString("TouchID/FaceID", comment: "")
        }
    }

    var imageName: String {
        switch self {
        case .changePassword:
            return "lock"
        case .changePasscode:
            return "passcodeChange"
        case .isPasscodeSetted:
            return "keypad"
        case .allowedBiometricSignIn:
            return "touch"
        }
    }
}
