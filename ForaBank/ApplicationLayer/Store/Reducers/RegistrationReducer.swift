//
//  RegistrationReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 23/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift

func registrationReducer(state: RegistrationState?, action: Action) -> RegistrationState {
    var newState = state ?? initialRegistration()
    
    switch action {
    case _ as ReSwiftInit:
        break
    case let action as SetLoginPwd:
        newState.login = action.login
        newState.pwd = action.pwd
        break
    case let action as SetPasscode:
        newState.passcode = action.passcode
        break
    default:
        break
    }
    
    return newState
}

func initialRegistration() -> RegistrationState {
    return RegistrationState(login: nil, pwd: nil, passcode: nil)
}
