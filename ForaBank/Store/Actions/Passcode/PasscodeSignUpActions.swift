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

let startPasscodeSingUp = Thunk<State> { dispatch, getState in
    dispatch(UpdatePasscodeSingUpProcess(isFinished: false, isStarted: true))
}

func enterCode(code: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        if let first = getState()?.passcodeSignUpState.passcodeFirst {
            guard first == code else {
                dispatch(AddCounter())
                return
            }

            dispatch(createPasscode(passcode: code))
            dispatch(UpdatePasscodeSingUpProcess(isFinished: true, isStarted: false))
            dispatch(ClearSignUpProcess())
            return
        }

        dispatch(SetFirstPasscode(firstPasscode: code))
    }
}

func createPasscode(passcode: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        if let encryptedPasscode = encrypt(passcode: passcode) {
            savePasscodeToKeychain(passcode: encryptedPasscode)
        }
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

struct ClearSignUpProcess: Action {
}
