//
//  Info+ext.swift
//
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import PaymentComponents
import SwiftUI

extension Info {
    
    public static func preview(
        info: GetSberQRDataResponse.Parameter.Info
    ) -> Self {
        
        .init(
            id: info.infoID,
            value: info.value,
            title: info.title,
            image: .init(.init("sparkles.tv")),
            style: .expanded
        )
    }
}

private extension GetSberQRDataResponse.Parameter.Info {
    
    var infoID: Info.ID {
        
        switch id {
        case .amount:        return .amount
        case .brandName:     return .brandName
        case .recipientBank: return .recipientBank
        }
    }
}
