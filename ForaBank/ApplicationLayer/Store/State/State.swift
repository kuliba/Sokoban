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
    let authenticationState: AuthenticationState
    let userState: UserState
    let productsState: ProductState

    let registrationState: RegistrationState
    let passcodeSignUpState: PasscodeSignUpState
    let passcodeSignInState: PasscodeSignInState

    let verificationCodeState: VerificationCodeState
}
