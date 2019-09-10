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
    var state = state ?? initialPasscodeSignUpState()

    switch action {
    case _ as ReSwiftInit:
        break
    case let action as SetFirstPasscode:
        state.passcodeFirst = action.firstPasscode
    case let action as UpdatePasscodeSingUpProcess:
        state.isStarted = action.isStarted
        state.isFinished = action.isFinished
    case _ as AddCounter:
        state.counter = state.counter + 1
    default:
        break
    }

    return state
}

func initialPasscodeSignUpState() -> PasscodeSignUpState {
    return PasscodeSignUpState(isStarted: false, isFinished: false, passcodeFirst: nil, passcodeSecond: nil, counter: 0)
}
