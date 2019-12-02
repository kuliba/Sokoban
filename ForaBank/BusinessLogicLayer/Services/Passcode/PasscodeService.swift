//
//  PasscodeService.swift
//  ForaBank
//
//  Created by MacAdmin on 02.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PasscodeService: IPasscodeService {

    static let shared = PasscodeService(shouldAskPasscode: false)
    
    var isPasscodeSetted: Bool {
        return (keychainCredentialsPasscode() != nil) && SettingsStorage.shared.isSetPasscode() ? true : false
    }
    var shouldAskPasscode: Bool
    var refresher: PasscodeRefresher?

    init(shouldAskPasscode: Bool) {
        self.shouldAskPasscode = shouldAskPasscode
    }
}

extension PasscodeService: IRefreshing {
    func refresh() {
        
    }
}
