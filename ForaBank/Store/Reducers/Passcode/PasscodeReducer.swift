//
//  PasscodeReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift

func passcodeReducer(state: State?, action: Action) -> State {
    var state = state ?? State(isScreenLocked: false, passcodeSignUpState: initialPasscodeSignUpState())

    switch action {
    case _ as ReSwiftInit:
        break
    case _ as SetPasscode:
        state.isScreenLocked = !state.isScreenLocked
    default:
        break
    }

    return state
}
