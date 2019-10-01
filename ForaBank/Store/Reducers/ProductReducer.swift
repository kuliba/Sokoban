//
//  ProductReducer.swift
//  ForaBank
//
//  Created by Бойко Владимир on 25/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift

func productReducer(state: ProductState?, action: Action) -> ProductState {
    var newState = state ?? initialProductState()

    switch action {
    case _ as ReSwiftInit:
        break
    case let action as SetPaymentOptions:
        newState.sourceOption = action.sourceOption
        newState.destinationOption = action.destinationOption
        break
    case let action as SelectProduct:
        newState.selectedProduct = action.product
        break
    case _ as ClearProductSelection:
        newState.selectedProduct = nil
        break
    default:
        break
    }

    return newState
}

func initialProductState() -> ProductState {
    return ProductState(sourceOption: nil, destinationOption: nil, selectedProduct: nil)
}
