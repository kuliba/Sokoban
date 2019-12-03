//
//  PasscodeServiceInitializer.swift
//  ForaBank
//
//  Created by MacAdmin on 02.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PasscodeServiceInitializer {
    class func createPasscodeService() -> IPasscodeService {
        
        let passcodeService = PasscodeService(shouldAskPasscode: true)
        let configurator = PasscodeServiceConfigurator()
        configurator.configure(passcodeService: passcodeService)
        return passcodeService
    }
}
