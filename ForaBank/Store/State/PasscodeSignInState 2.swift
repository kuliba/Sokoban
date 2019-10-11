//
//  PasscodeSignInState.swift
//  ForaBank
//
//  Created by Бойко Владимир on 11/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift

struct PasscodeSignInState: StateType {
    var isShown: Bool
    var failCounter: Int
}
