//
//  IPasscodeService.swift
//  ForaBank
//
//  Created by MacAdmin on 02.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IPasscodeService: class {
    var isPasscodeSetted: Bool { get }
    var allowedPasscode: Bool { get }
    var isSetNonDisplayBlockProducts: Bool { get }
    
    func showPasscodeScreen()
    func cancelPasscodeAuth()
}
