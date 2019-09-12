//
//  AuthenticationActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 11/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

let checkAuthCredentials = Thunk<State> { dispatch, getStat in
    guard let passcode = keychainCredentialsPasscode() else {
        return
    }
    // let login = keychainCredentialsLogin(), let pwd = keychainCredentialsPwd()
    dispatch(UpdatePasscodeSingInProcess(isShown: true))
}
//
//func enterCode(code: String) -> Thunk<State> {
//    return Thunk<State> { dispatch, getState in
//        if let first = getState()?.passcodeSignUpState.passcodeFirst {
//            guard first == code else {
//                dispatch(AddCounter())
//                return }
//
//            dispatch(createPasscode(passcode: code))
//            dispatch(UpdatePasscodeSingUpProcess(isFinished: true, isStarted: false))
//            dispatch(ClearSignUpProcess())
//        }
//
//        dispatch(SetFirstPasscode(firstPasscode: code))
//    }
//}
//
//func createPasscode(passcode: String) -> Thunk<State> {
//    return Thunk<State> { dispatch, getState in
//        let key = aesKey32Dumb(with: passcode)
//        let iv = aesInitializationVector16Dump()
//
//        if let encryptedPasscode = try! passcode.aesEncrypt(withKey: key, iv: iv) {
//            savePasscodeToKeychain(passcode: encryptedPasscode)
//        }
//    }
//}
//
//struct SetFirstPasscode: Action {
//    let firstPasscode: String
//}
//
//struct UpdateAuthProcess: Action {
//    let canStartAuth: Bool
//}
//
//struct AddCounter: Action {
//}
//
//struct ClearSignUpProcess: Action {
//}
