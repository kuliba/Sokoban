//
//  PasscodeServiceConfigurator.swift
//  ForaBank
//
//  Created by MacAdmin on 02.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PasscodeServiceConfigurator {

    func configure(passcodeService: PasscodeService) {
        passcodeService.refresher = Refresher(target: passcodeService)
    }
}
