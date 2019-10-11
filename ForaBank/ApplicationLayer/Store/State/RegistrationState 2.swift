//
//  RegistrationState.swift
//  ForaBank
//
//  Created by Бойко Владимир on 23/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift

struct RegistrationState: StateType {
    var login: String?
    var pwd: String?
    var passcode: String?
}
