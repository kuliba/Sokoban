//
//  IAuthenticationService.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03.12.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol IAuthenticationService {
    typealias AuthenticationRefresher = Refresher<AuthenticationService>

    var refresher: AuthenticationRefresher? { get }
    var isAuthorized: Bool { get }

    func afterLogin()
    func startSecurityCheckIfNeeded()
    func onAuthCanceled()
    func logout()
}
