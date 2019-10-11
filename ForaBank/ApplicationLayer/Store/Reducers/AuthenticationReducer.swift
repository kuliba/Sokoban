//
//  AuthenticationReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 11/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift

func authenticationReducer(state: AuthenticationState?, action: Action) -> AuthenticationState {
    var newState = state ?? initialAuthentication()

    switch action {
    case _ as ReSwiftInit:
        break
//    case let action as UpdateAuthProcess:
//        newState.canStartAuth = action.canStartAuth
//        break
    default:
        break
    }

    return newState
}

func initialAuthentication() -> AuthenticationState {
    return AuthenticationState(canStartAuth: false)
}
