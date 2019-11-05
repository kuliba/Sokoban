//
//  PasscodeSignInReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 12/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift

func passcodeSignInReducer(state: PasscodeSignInState?, action: Action) -> PasscodeSignInState {
    var newState = state ?? initialPasscodeSignInState()

    switch action {
    case _ as ReSwiftInit:
        break
    case _ as ClearPasscodeSignInProcess:
        newState = initialPasscodeSignInState()
        break
    case let action as UpdatePasscodeSingInProcess:
        newState.isShown = action.isShown
        break
    case _ as AddSignInCounter:
        newState.failCounter = (state?.failCounter ?? 0) + 1
        break
    default:
        break
    }

    return newState
}

func initialPasscodeSignInState() -> PasscodeSignInState {
    return PasscodeSignInState(isShown: false, failCounter: 0)
}
