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
    var isLoading: Bool = false {
        didSet {
            loadingCallback!(isLoading)
        }
    }
    var loadingCallback: ((_ isLoaing: Bool) -> ())?

    func getData(completion: @escaping ([IPresentationModel]) -> ()) {
        isLoading = true
        NetworkManager.shared().allPaymentOptions { [weak self] (success, paymentOptions) in
            guard success, let options = paymentOptions else {
                return
            }
            self?.isLoading = false
            completion(options)
        }
    }
}
