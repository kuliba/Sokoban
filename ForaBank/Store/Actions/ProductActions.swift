//
//  ProductActions.swift
//  ForaBank
//
//  Created by Бойко Владимир on 25/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

func startPayment(withOption option: PaymentOption) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        showPaymentViewController()
        dispatch(SetPaymentOptions(paymentOption: option))
    }
}

func finishPayment() -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(ClearPaymentProcess())
    }
}

func selectedProduct(product: IProduct) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(SelectProduct(product: product))
    }
}

func deselectedProduct() -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(ClearProductSelection())
    }
}

struct SetPaymentOptions: Action {
    let paymentOption: PaymentOption
}

struct ClearPaymentProcess: Action {
}

struct SelectProduct: Action {
    let product: IProduct
}

struct ClearProductSelection: Action {
}
