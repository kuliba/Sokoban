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
    
    func getData(completion: ([IPresentationModel]) -> ()) {
        
    }
    
    var isLoading: Bool = false
    

    func getAllPaymentOptions() {
        allPaymentOptions { (success, paymentOptions) in
            return paymentOptions
        }
    }
    
    
}
