//
//  IPasscodeService.swift
//  ForaBank
//
//  Created by MacAdmin on 02.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IPasscodeService: class {
    typealias PasscodeRefresher = Refresher<PasscodeService>

    var refresher: PasscodeRefresher? {get}
    var shouldAskPasscode: Bool {get}
    var isPasscodeSetted: Bool {get}
    
    func startAuthIfNeeded()
}
