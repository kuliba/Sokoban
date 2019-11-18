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

let fetchProducts = Thunk<State> { dispatch, getState in
    NetworkManager.shared().getProducts { (success, products) in
        guard let nonNilProducts = products else {
            return
        }
        dispatch(didReviceProducts(products: nonNilProducts))
    }
}

let invalidateCurrentProducts = Thunk<State> { dispatch, getState in
    dispatch(SetProductsUpToDate(isUpToDateProducts: false))
}

func didReviceProducts(products: [Product]) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(SetProducts(products: products))
        dispatch(SetProductsUpToDate(isUpToDateProducts: true))
    }
}

func startPayment(sourceOption: PaymentOption?, destionationOption: PaymentOption?) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
//        showPaymentViewController()
        showPaymentsTableViewController()
        dispatch(SetPaymentOptions(sourceOption: sourceOption, destinationOption: destionationOption))
    }
}

func payment(sourceOption: PaymentOption?, destionationOption: PaymentOption?, sum: String?) -> Thunk<State> {
    return Thunk<State> { dispatch, getState in
        dispatch(SetPayment(sourceOption: sourceOption, destinationOption: destionationOption, sum: sum))
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

struct SetProducts: Action {
    let products: [Product]
}

struct SetProductsUpToDate: Action {
    let isUpToDateProducts: Bool
}

struct SetPaymentOptions: Action {
    let sourceOption: PaymentOption?
    let destinationOption: PaymentOption?
}

struct SetPayment: Action {
    let sourceOption: PaymentOption?
    let destinationOption: PaymentOption?
    let sum: String?
}

struct SelectProduct: Action {
    let product: IProduct
}

struct ClearProductSelection: Action {
}
