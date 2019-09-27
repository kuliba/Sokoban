//
//  ProductsState.swift
//  ForaBank
//
//  Created by Бойко Владимир on 25/09/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import ReSwift

struct ProductState: Action {
    var sourceOption: PaymentOption?
    var destinationOption: PaymentOption?
    var selectedProduct: IProduct?
}
