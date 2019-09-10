//
//  PasscodeSignUpActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

let startPasscodeSingUp = Thunk<State> { dispatch, getStat in
    dispatch(CleanSignUpProcess())
    dispatch(UpdatePasscodeSingUpProcess(isFinished: false, isStarted: true))
}

func enterCode(code: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in

        if let first = getState()?.passcodeSignUpState.passcodeFirst {
            guard first == code else {
                dispatch(AddCounter())
                return }
            dispatch(UpdatePasscodeSingUpProcess(isFinished: true, isStarted: false))
        }

        dispatch(SetFirstPasscode(firstPasscode: code))
    }
}

struct SetFirstPasscode: Action {
    let firstPasscode: String
}

struct UpdatePasscodeSingUpProcess: Action {
    let isFinished: Bool
    let isStarted: Bool
}

struct AddCounter: Action {
}

struct CleanSignUpProcess: Action {
}
