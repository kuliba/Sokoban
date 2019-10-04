//
//  PaymentOptionCellProvider.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

class PaymentOptionCellProvider: ICellProvider {
    var currentValue: IPresentationModel?
    var isLoading: Bool = false

    func getData(completion: @escaping ([IPresentationModel]) -> ()) {
        allPaymentOptions { (success, paymentOptions) in
            guard success, let options = paymentOptions as? [PaymentOption] else {
                return
            }
            completion(options)
        }
    }
}
