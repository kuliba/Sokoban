//
//  Model+isSberQR.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

extension Model {
    
    func isSberQR(_ url: URL) -> Bool {
        
        let contents = qrPaymentType.value
            .filter { $0.paymentType == .sberQR }
            .map(\.content)
        
        return url.matches(contents: contents)
    }
}

private extension String {
    
    static let sberQR = "SBERQR"
}
