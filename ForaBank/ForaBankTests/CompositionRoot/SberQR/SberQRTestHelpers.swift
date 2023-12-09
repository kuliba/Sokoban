//
//  SberQRTestHelpers.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

import SberQR

extension Array where Element == GetSberQRDataResponse.Parameter {
    
    var hasProductSelect: Bool {
        
        !allSatisfy {
            
            switch $0 {
            case .productSelect:
                return false
                
            default:
                return true
            }
        }
    }
}
