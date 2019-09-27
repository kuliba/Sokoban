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

func startPayment(sourceOption: PaymentOption?, destionationOption: PaymentOption?) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        showPaymentViewController()
        dispatch(SetPaymentOptions(sourceOption: sourceOption, destinationOption: destionationOption))
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
    let sourceOption: PaymentOption?
    let destinationOption: PaymentOption?
}

struct SelectProduct: Action {
    let product: IProduct
}

struct ClearProductSelection: Action {
}
