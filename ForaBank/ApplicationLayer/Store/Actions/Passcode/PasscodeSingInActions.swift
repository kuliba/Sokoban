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

let manageWrongPasscode = Thunk<State> { dispatch, getState in
    guard let fails = getState()?.passcodeSignInState.failCounter, fails < 2 else {
        AuthenticationService.shared.logoutAndClearAllUserData()
        dispatch(UpdatePasscodeSingInProcess(isShown: false))
        return
    }
    dispatch(AddSignInCounter())
}

let canceledPasscodeSignIn = Thunk<State> { dispatch, getState in
    dispatch(UpdatePasscodeSingInProcess(isShown: false))
}

let clearPasscodeData = Thunk<State> { dispatch, getState in
    removeAllKeychainItems()
}

func startSignInWith(passcode: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        guard passcode == keychainCredentialsPasscode() else {
            dispatch(manageWrongPasscode)
            return
        }
        dispatch(signIn(passcode: passcode))
    }
}

let startSignInWithBiometric = Thunk<State> { dispatch, getState in
    dispatch(signIn(passcode: nil))
}


func signIn(passcode: String?) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        guard let encryptedUserData = keychainCredentialsUserData() else {
            return
        }

        var userData: UserData?
        if let passcode = passcode {
            userData = decryptUserData(userData: encryptedUserData, withPossiblePasscode: passcode)
        } else if let passcode = keychainCredentialsPasscode() {
            userData = decryptUserData(userData: encryptedUserData, withPossiblePasscode: passcode)
        }
        guard let nonNilUserData = userData else {
            return
        }
        NetworkManager.shared().login(login: nonNilUserData.login,
                                      password: nonNilUserData.pwd,
                                      completionHandler: { success, errorMessage in
                                          if success {
                                              dispatch(startVerification)
                                          }
                                      })
    }
}

struct UpdatePasscodeSingInProcess: Action {
    var isShown: Bool
}

struct AddSignInCounter: Action {
}

struct ClearPasscodeSignInProcess: Action {
}
