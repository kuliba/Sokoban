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
    case bankSPBDefoult
    case setUpApplePay
    case nonDisplayBlockProduct(() -> Bool)
    case blockUser

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
        case .bankSPBDefoult:
            if UserDefaults.standard.string(forKey: "SPBBankDefault") != nil{
                return NSLocalizedString("Изменить банк в СБП по умолчанию", comment: "")
            }
            return NSLocalizedString("Установка банка в СБП по умолчанию", comment: "")
        case .setUpApplePay:
            return NSLocalizedString("Установка ApplePay", comment: "")
        case .nonDisplayBlockProduct:
            return NSLocalizedString("Отображать заблокированные продукты", comment: "")
        case .blockUser:
            return NSLocalizedString("Заблокировать аккаунт", comment: "")
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
        case .bankSPBDefoult:
            return "sbp-logoDefault"
        case .setUpApplePay:
            return ""
        case .nonDisplayBlockProduct:
            return "lock"
       case .blockUser:
            return "trash"
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
        case .bankSPBDefoult:
            return false
        case .setUpApplePay:
            return false
        case .nonDisplayBlockProduct:
            return true
        case .blockUser:
            return false
        }
        
    }

    var isActive: Bool {
        switch self {
        case .changePassword:
            return true
        case .changePasscode:
            return SettingsStorage.shared.isSetPasscode()
        case .allowedPasscode:
            return PasscodeService.shared.isPasscodeSetted
        case .allowedBiometricSignIn:
            return PasscodeService.shared.isPasscodeSetted && SettingsStorage.shared.isSetPasscode()
        case .bankSPBDefoult:
            return true
        case .setUpApplePay:
            return true
        case .nonDisplayBlockProduct:
            return UserDefaults.standard.bool(forKey: "mySwitchValue")
//
//            return UserDefaults.standard.bool(forKey: "mySwitchValue")
        case .blockUser:
            return true
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
    public static func isNonBlocketProduct() -> Void {
       
    }

    public static func allowedBiometricSignInDefault() -> UserSettingType {
        return UserSettingType.allowedBiometricSignIn { () -> Bool in
            return SettingsStorage.shared.allowedBiometricSignIn() && SettingsStorage.shared.isSetPasscode() && PasscodeService.shared.isPasscodeSetted
        }
    }
    public static func isNonBlockedProductDefault() -> UserSettingType {
        return UserSettingType.nonDisplayBlockProduct { () -> Bool in
            return UserDefaults.standard.bool(forKey: "mySwitchValue")
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
//        case .nonDisplayBlockProduct(_):
////            let currentValue = SettingsStorage.shared.isSetPasscode()
////            SettingsStorage.shared.setIsSetPasscode(!currentValue)
//            break
        default:
            break
        }
    }
}
