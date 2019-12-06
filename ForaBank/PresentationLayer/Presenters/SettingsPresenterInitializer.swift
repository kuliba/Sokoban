//
//  SettingsPresenterInitializer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class SettingsPresenterInitializer {
    class func createSettingsPresenter(withDelegate delegate: SettingsPresenterDelegate) -> ISettingsPresenter {
        let settingsPresenter = SettingsPresenter(options: [UserSettingType.changePasscode,
                                                            UserSettingType.isPasscodeSettedDefault(),
                                                            UserSettingType.allowedBiometricSignInDefault(),
                                                            UserSettingType.changePasscode], delegate: delegate)
        return settingsPresenter
    }
}
