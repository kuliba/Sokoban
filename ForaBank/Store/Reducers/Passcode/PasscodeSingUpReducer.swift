//
//  PasscodeSingUpReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift

func passcodeSignUpReducer(state: PasscodeSignUpState?, action: Action) -> PasscodeSignUpState {
    var newState = state ?? initialPasscodeSignUpState()

    switch action {
    case _ as ReSwiftInit:
        break
    case _ as ClearSignUpProcess:
        newState = initialPasscodeSignUpState()
        break
    case let action as SetFirstPasscode:
        newState.passcodeFirst = action.firstPasscode
        break
    case let action as UpdatePasscodeSingUpProcess:
        newState.isStarted = action.isStarted
        newState.isFinished = action.isFinished
        break
    case _ as AddCounter:
        newState.counter = (state?.counter ?? 0) + 1
        break
    default:
        break
    }

    return newState
}

func initialPasscodeSignUpState() -> PasscodeSignUpState {
    return PasscodeSignUpState(isStarted: false, isFinished: false, passcodeFirst: nil, passcodeSecond: nil, counter: 0)
}
