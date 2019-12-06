//
//  AuthenticationServiceConfigurator.swift
//  ForaBank
//
//  Created by Бойко Владимир on 04.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class AuthenticationServiceConfigurator {
    
    func configure(authenticationService: AuthenticationService) {
        authenticationService.refresher = Refresher(target: authenticationService)
    }
}
