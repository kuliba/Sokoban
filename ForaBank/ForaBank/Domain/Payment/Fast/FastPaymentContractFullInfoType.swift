//
//  FastPaymentContractFullInfoType.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 21.06.2022.
//

import Foundation

struct FastPaymentContractFullInfoType: Codable, Equatable {
    
    let fastPaymentContractAccountAttributeList: [FastPaymentContractAccountAttributeTypeData]?
    let fastPaymentContractAttributeList: [FastPaymentContractAttributeTypeData]?
    let fastPaymentContractClAttributeList: [FastPaymentContractClAttributeTypeData]?
}
