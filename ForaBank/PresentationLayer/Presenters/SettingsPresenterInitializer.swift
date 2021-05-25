//
//  SettingsPresenterInitializer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class SettingsPresenterInitializer {
    class func createSettingsPresenter(withDelegate delegate: SettingsPresenterDelegate) -> SettingsPresenter {
        let settingsPresenter = SettingsPresenter(options: [UserSettingType.changePassword,
                                                            UserSettingType.isPasscodeSettedDefault(),
                                                            UserSettingType.allowedBiometricSignInDefault(),
                                                            UserSettingType.changePasscode,
                                                            UserSettingType.isNonBlockedProductDefault(),
                                                            UserSettingType.bankSPBDefoult,
//                                                            UserSettingType.setUpApplePay,
                                                            UserSettingType.blockUser], delegate: delegate)
        return settingsPresenter
    }
}
