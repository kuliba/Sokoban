//
//  PasscodeService.swift
//  ForaBank
//
//  Created by MacAdmin on 02.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PasscodeService: IPasscodeService {

    static let shared = PasscodeServiceInitializer.createPasscodeService()
    
    var isPasscodeSetted: Bool {
        return (keychainCredentialsPasscode() != nil) && SettingsStorage.shared.isSetPasscode() ? true : false
    }
    var shouldAskPasscode: Bool {
        didSet{
            
        }
    }
    var refresher: PasscodeRefresher?

    init(shouldAskPasscode: Bool) {
        self.shouldAskPasscode = shouldAskPasscode
    }
    
    public func startAuthIfNeeded() {
        guard shouldAskPasscode else {
            return
        }
        
        store.dispatch(checkAuthCredentials)
        shouldAskPasscode = false
    }
}

extension PasscodeService: IRefreshing {
    func refresh() {
        shouldAskPasscode = true
    }
}
