//
//  PasscodeState.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift

struct PasscodeSignUpState: StateType {
    var isStarted: Bool
    var isFinished: Bool
    var passcodeFirst: String?
    var passcodeSecond: String?
    var counter: Int
}
