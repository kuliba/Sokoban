//
//  AntifraudViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 15.12.2021.
//


import Combine
import UIKit

class AntifraudViewModel {
    
    let phoneNumber: String
    let name: String
    let amount: String
    let status: String?
    
    var model: CreateSFPTransferDecodableModel
    
    init(model: CreateSFPTransferDecodableModel, phoneNumber: String) {
        
        self.model = model
        self.amount = "- \(model.data?.amount?.currencyFormatter(symbol: model.data?.currencyAmount ?? "") ?? "")"
        self.name = "\(model.data?.payeeName ?? "")."
        self.phoneNumber = phoneNumber
        let data = model.data?.additionalList?.filter({$0.fieldName == "AFResponse"})
//        if data?.count ?? 0 > 0{
        self.status = data?[0].fieldValue
//        }
    }
    

}
