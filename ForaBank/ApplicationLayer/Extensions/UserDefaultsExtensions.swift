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
        static let needSetPasscodeKey = "needSetPasscode"
    }

    func isFirstLaunch() -> Bool {
        return !bool(forKey: Constants.firstLaunchKey)
    }

    func setFirstLaunch() {
        set(true, forKey: Constants.firstLaunchKey)
    }

    func setNeedSetPasscode(_ needs: Bool) {
        set(needs, forKey: Constants.needSetPasscodeKey)
    }
    func isNeedSetPasscode() -> Bool {
        return bool(forKey: Constants.needSetPasscodeKey)
    }
}
