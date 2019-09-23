//
//  File.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift

struct State: StateType {
    var passcodeSignUpState: PasscodeSignUpState
    var authenticationState: AuthenticationState
    let passcodeSignInState: PasscodeSignInState
    let verificationCodeState: VerificationCodeState
}

//typealias Bookmark = (route: [RouteElementIdentifier], routeSpecificData: Any?)
