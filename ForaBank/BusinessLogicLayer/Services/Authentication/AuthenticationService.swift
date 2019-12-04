//
//  AuthenticationService.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class AuthenticationService: IAuthenticationService {

    static let shared: IAuthenticationService = AuthenticationServiceInitializer.createAuthenticationService()

    private struct Constants {
        static let expireTime: TimeInterval = 1 * 60
    }

    var refresher: AuthenticationRefresher?
    var isAuthorized: Bool
    var isUserSessionAlive: Bool

    init(isAuthorized: Bool, isUserSessionAlive: Bool) {
        self.isAuthorized = isAuthorized
        self.isUserSessionAlive = isUserSessionAlive
    }

    //TODO: - Refactor
    func afterLogin() {
        isAuthorized = true
        isUserSessionAlive = true
        refresher?.launchTimer(repeats: false, timeInterval: Constants.expireTime)
    }

    func startSecurityCheckIfNeeded() {
        guard !isUserSessionAlive else { return }
        if PasscodeService.shared.isPasscodeSetted {
            PasscodeService.shared.showPasscodeScreen()
        } else {
            logout()
        }
    }

    func logout() {
        isAuthorized = false
        isUserSessionAlive = false
        store.dispatch(doLogout)
        refresher?.invalidateTimer()
    }

    func onAuthCanceled() {
        logout()
    }
}

extension AuthenticationService: IRefreshing {
    func refresh() {
        isUserSessionAlive = false
    }
}
