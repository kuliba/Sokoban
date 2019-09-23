//
//  StateActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 20/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

func startPayment(withOption option: PaymentOption) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(SetPaymentOptions(paymentOption: option))
    }
}

func finishPayment() -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(ClearPaymentProcess())
    }
}

struct SetPaymentOptions: Action {
    let paymentOption: PaymentOption
}

struct ClearPaymentProcess: Action {
}
