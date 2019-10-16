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
import KeychainAccess

let startPasscodeSingUp = Thunk<State> { dispatch, getState in
    unsafeRemovePasscodeFromKeychain()
    unsafeRemoveEncryptedPasscodeFromKeychain()
    unsafeRemoveUserDataFromKeychain()
    dispatch(UpdatePasscodeSingUpProcess(isFinished: false, isStarted: true))
}

let finishPasscodeSingUp = Thunk<State> { dispatch, getState in
    dispatch(createPasscode)
    dispatch(ClearSignUpProcess())
}

let createPasscode = Thunk<State> { dispatch, getState in
        guard let passcode = getState()?.passcodeSignUpState.passcodeSecond else {
            return
        }
        savePasscodeToKeychain(passcode: passcode)
        if let encryptedPasscode = encrypt(passcode: passcode) {
            saveEncryptedPasscodeToKeychain(passcode: encryptedPasscode)
        }
        dispatch(createdPasscode(passcode: passcode))
        dispatch(finishRegistration)
}

func enterCode(code: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        if let first = getState()?.passcodeSignUpState.passcodeFirst {
            guard first == code else {
                dispatch(AddCounter())
                return
            }
            dispatch(SetSecondPasscode(passcodeSecond: code))
            dispatch(UpdatePasscodeSingUpProcess(isFinished: true, isStarted: false))
            return
        }
        dispatch(SetFirstPasscode(passcodeFirst: code))
    }
}

struct SetFirstPasscode: Action {
    let passcodeFirst: String
}

struct SetSecondPasscode: Action {
    let passcodeSecond: String
}

struct UpdatePasscodeSingUpProcess: Action {
    let isFinished: Bool
    let isStarted: Bool
}

struct AddCounter: Action {
}

struct ClearSignUpProcess: Action {
}
