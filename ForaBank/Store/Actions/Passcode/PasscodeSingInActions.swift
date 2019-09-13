//
//  PasscodeSingInActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 12/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

let startPasscodeSingIn = Thunk<State> { dispatch, getState in
    dispatch(UpdatePasscodeSingInProcess(isShown: true))
}

let manageWrongPwd = Thunk<State> { dispatch, getState in
    guard let fails = getState()?.passcodeSignInState.failCounter, fails < 2 else {
        dispatch(UpdatePasscodeSingInProcess(isShown: false))
        return
    }
    dispatch(AddSignInCounter())
}

func signInWith(passcode: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        guard passcode == decryptPasscode(withPossiblePasscode: passcode) else {
            dispatch(manageWrongPwd)
            return
        }
        dispatch(UpdatePasscodeSingInProcess(isShown: false))
        dispatch(ClearSignInProcess())
    }
}

let signInWithBiometric = Thunk<State> { dispatch, getState in
    dispatch(UpdatePasscodeSingInProcess(isShown: false))
    dispatch(ClearSignInProcess())
}

struct UpdatePasscodeSingInProcess: Action {
    var isShown: Bool
}

struct AddSignInCounter: Action {
}

struct ClearSignInProcess: Action {
}
