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
    guard PasscodeService.shared.isPasscodeSetted else {
        return
    }
    dispatch(UpdatePasscodeSingInProcess(isShown: true))
}

let userDidSignIn = Thunk<State> { dispatch, getStat in
    dispatch(fetchUserData)
    dispatch(fetchProducts)
    setupAuthorizedZone()
}

let doLogout = Thunk<State> { dispatch, getStat in
    NetworkManager.shared().logOut { (success) in
        if success {
            setupUnauthorizedZone()
            dispatch(clearPasscodeData)
        }
    }
}

func createCredentials(login: String, pwd: String) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        guard let passcode = keychainCredentialsPasscode(), let encryptedUserData = encrypt(userData: UserData(login: login, pwd: pwd), withPasscode: passcode) else {
            return
        }
        saveUserDataToKeychain(userData: encryptedUserData)
    }
}
