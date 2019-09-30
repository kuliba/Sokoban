//
//  StateReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 20/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift

func stateReducer(state: State?, action: Action) -> State {
    let newState = state ?? appReducer(action: action, state: state)

    switch action {
    case _ as ReSwiftInit:
        break
    default:
        break
    }

    return newState
}
