//
//  PasscodeService.swift
//  ForaBank
//
//  Created by MacAdmin on 02.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PasscodeService: IPasscodeService {

    static let shared: IPasscodeService = PasscodeServiceInitializer.createPasscodeService()

    var isPasscodeSetted: Bool {
        return keychainCredentialsPasscode() != nil ? true : false
    }

    var allowedPasscode: Bool {
        return SettingsStorage.shared.isSetPasscode() ? true : false
    }

    init() {
    }

    public func showPasscodeScreen() {
        guard isPasscodeSetted && allowedPasscode else {
            return
        }
        store.dispatch(checkAuthCredentials)
    }

    public func cancelPasscodeAuth() {
        AuthenticationService.shared.onAuthCanceled()
        store.dispatch(canceledPasscodeSignIn)
    }
}
