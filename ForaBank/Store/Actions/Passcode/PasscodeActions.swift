//
//  PasscodeActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 09/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

let setPasscode = Thunk<State> { dispatch, getState in
    //guard let config = getState()?.authenticationState.oAuthConfig else { return }

//    let url = config.authenticate()
//
//    if let url = url {
//        dispatch(SetOAuthURL(oAuthUrl: url))
//        dispatch(SetRouteAction([loginRoute, oAuthRoute]))
//    }
    
    dispatch(SetPasscode(isPasscodeVisiable: true))
}


struct SetPasscode: Action {
    let isPasscodeVisiable: Bool
}

