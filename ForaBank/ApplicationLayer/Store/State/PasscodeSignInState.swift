//
//  PasscodeSignInState.swift
//  ForaBank
//
//  Created by Бойко Владимир on 11/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift

func isEqual(first:PasscodeSignInState, to second: PasscodeSignInState) -> Bool {
    return first.isShown == second.isShown && first.failCounter == second.failCounter
}

struct PasscodeSignInState: StateType {
    var isShown: Bool
    var failCounter: Int
}
