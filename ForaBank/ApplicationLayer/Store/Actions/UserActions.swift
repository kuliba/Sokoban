//
//  UserActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 25.10.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

let fetchUserData = Thunk<State> { dispatch, getState in
    NetworkManager.shared().getProfile { (success, profile, errorMessage) in
        guard let nonNilProfile = profile else { return }
        dispatch(SetUserProfile(profile: nonNilProfile))
    }
}

struct SetUserProfile: Action {
    let profile: Profile
}
