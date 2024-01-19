//
//  FPSCFLResponse+ext.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 28.12.2023.
//

@testable import ForaBank

extension FastPaymentsServices.FPSCFLResponse {
    
    static func active(
        _ phone: FastPaymentsServices.Phone
    ) -> Self {
        
        .contract(.init(phone: phone, status: .active))
    }
    
    static func inactive(
        _ phone: FastPaymentsServices.Phone
    ) -> Self {
        
        .contract(.init(phone: phone, status: .inactive))
    }
}
