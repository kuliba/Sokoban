//
//  ISettingsPresenter.swift
//  ForaBank
//
//  Created by Бойко Владимир on 05.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol SettingsPresenterDelegate: class {

}

protocol ISettingsPresenter: class {
    var options: Array<UserSettingType> { get }
    var delegate: SettingsPresenterDelegate? { get }
}
