//
//  UserReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 25.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift

func userReducer(state: UserState?, action: Action) -> UserState {
    var newState = state ?? initialUserState()

    switch action {
    case _ as ReSwiftInit:
        break

    case let action as SetUserProfile:
        newState.profile = action.profile
        break
    default:
        break
    }
    return newState
}

func initialUserState() -> UserState {
    return UserState(profile: nil)
}
