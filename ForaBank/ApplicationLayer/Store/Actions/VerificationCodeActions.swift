//
//  VerificationCodeActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 18/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

let startVerification = Thunk<State> { dispatch, getState in
    dispatch(UpdateVerificationProcess(isShown: true))
}

let finishVerification = Thunk<State> { dispatch, getState in
    dispatch(UpdateVerificationProcess(isShown: false))
    dispatch(UpdatePasscodeSingInProcess(isShown: false))
    dispatch(ClearPasscodeSignInProcess())
    NetworkManager.shared().isSignedIn { (isSignIn) in
        if isSignIn {
            dispatch(userDidSignIn)
        }
    }
}

struct UpdateVerificationProcess: Action {
    var isShown: Bool
}
