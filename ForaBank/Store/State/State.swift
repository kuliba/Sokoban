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
    var isScreenLocked = false
    var passcodeSignUpState: PasscodeSignUpState
//    var authenticationState: AuthenticationState
//    var repositories: Response<[Repository]>?
//    var bookmarks: [Bookmark]
}

//typealias Bookmark = (route: [RouteElementIdentifier], routeSpecificData: Any?)
