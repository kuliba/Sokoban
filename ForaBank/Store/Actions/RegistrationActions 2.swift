//
//  RegistrationActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 23/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

let finishRegistration = Thunk<State> { dispatch, getState in
    guard let state = getState(), let passcode = state.registrationState.passcode, let login = state.registrationState.login, let pwd = state.registrationState.pwd else { return }
    guard let encryptedUserData = encrypt(userData: UserData(login: login, pwd: pwd), withPasscode: passcode) else {
        return
    }
    saveUserDataToKeychain(userData: encryptedUserData)
}

func createdLoginPwd(login: String, pwd: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(SetLoginPwd(login: login, pwd: pwd))
    }
}

func createdPasscode(passcode: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(SetPasscode(passcode: passcode))
    }
}

struct SetLoginPwd: Action {
    var login: String
    var pwd: String

}

struct SetPasscode: Action {
    var passcode: String
}
