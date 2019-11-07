//
//  ISettingsStorage.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol ISettingsStorage {
    func isFirstLaunch() -> Bool
    func setFirstLaunch()
    func setIsSetPasscode(_ needs: Bool)
    func isSetPasscode() -> Bool
    func invalidateUserSettings()
}
