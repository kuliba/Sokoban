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
    case allowedPasscode(() -> Bool)
    case allowedBiometricSignIn(() -> Bool)

    var localizedName: String {
        switch self {
        case .changePassword:
            return NSLocalizedString("Изменить пароль", comment: "")
        case .changePasscode:
            return NSLocalizedString("Изменить 4-х значный код", comment: "")
        case .allowedPasscode:
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
        case .allowedPasscode:
            return "keypad"
        case .allowedBiometricSignIn:
            return "touch"
        }
    }

    var isToggable: Bool {
        switch self {
        case .changePassword:
            return false
        case .changePasscode:
            return false
        case .allowedPasscode:
            return true
        case .allowedBiometricSignIn:
            return true
        }
    }

    var isActive: Bool {
        switch self {
        case .changePassword:
            return true
        case .changePasscode:
            return false
        case .allowedPasscode:
            return PasscodeService.shared.isPasscodeSetted
        case .allowedBiometricSignIn:
            return PasscodeService.shared.isPasscodeSetted && SettingsStorage.shared.isSetPasscode()
        }
    }

    var localizedFieldName: String {
        return "Параметры входа"
    }

    public static func isPasscodeSettedDefault() -> UserSettingType {
        return UserSettingType.allowedPasscode { () -> Bool in
            return SettingsStorage.shared.isSetPasscode() && PasscodeService.shared.isPasscodeSetted
        }
    }

    public static func allowedBiometricSignInDefault() -> UserSettingType {
        return UserSettingType.allowedBiometricSignIn { () -> Bool in
            return SettingsStorage.shared.allowedBiometricSignIn() && SettingsStorage.shared.isSetPasscode() && PasscodeService.shared.isPasscodeSetted
        }
    }

    public func toggleValueIfPossiable() {
        guard isToggable else {
            return
        }
        switch self {
        case .allowedBiometricSignIn(_):
            let currentValue = SettingsStorage.shared.allowedBiometricSignIn()
            SettingsStorage.shared.setAllowedBiometricSignIn(allowed: !currentValue)
            break
        case .allowedPasscode(_):
            let currentValue = SettingsStorage.shared.isSetPasscode()
            SettingsStorage.shared.setIsSetPasscode(!currentValue)
            break
        default:
            break
        }
    }
}
