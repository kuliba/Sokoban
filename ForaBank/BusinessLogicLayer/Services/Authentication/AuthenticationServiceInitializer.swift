//
//  AuthenticationServiceInitializer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 04.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class AuthenticationServiceInitializer {
    class func createAuthenticationService() -> IAuthenticationService {

        let authenticationService = AuthenticationService(isAuthorized: false, isUserSessionAlive: false)
        let configurator = AuthenticationServiceConfigurator()
        configurator.configure(authenticationService: authenticationService)
        return authenticationService
    }
}
