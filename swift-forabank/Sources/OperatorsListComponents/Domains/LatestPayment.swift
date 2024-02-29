//
//  LatestPaymentData.swift
//
//
//  Created by Дмитрий Савушкин on 12.02.2024.
//

import Foundation

public struct LatestPaymentData {
    
    let amount: String
    let additionalList: [AdditionalItem]
    let serviceId: String
    
    struct AdditionalItem: Equatable {
        
        let fieldTitle: String?
        let fieldName: String
        let fieldValue: String
        let svgImage: String?
    }
}
