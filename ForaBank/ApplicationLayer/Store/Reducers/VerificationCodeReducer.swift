//
//  VerificationCodeReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 18/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift

func verificationCodeReducer(state: VerificationCodeState?, action: Action) -> VerificationCodeState {
    var newState = state ?? initialVerificationCodeState()

    switch action {
    case _ as ReSwiftInit:
        break
    case let action as UpdateVerificationProcess:
        newState.isShown = action.isShown
        break
    default:
        break
    }

    return newState
}

func initialVerificationCodeState() -> VerificationCodeState {
    return VerificationCodeState(isShown: false)
}
