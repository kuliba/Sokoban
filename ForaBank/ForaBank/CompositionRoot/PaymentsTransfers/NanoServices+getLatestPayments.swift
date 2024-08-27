//
//  NanoServices+getLatestPayments.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import Foundation

extension NanoServices {
    
    static func getLatestPayments(
        categories: [ServiceCategory],
        completion: @escaping ([Latest]) -> Void
    ) {
        #warning("replace stub with implementation")
        DispatchQueue.global(qos: .userInitiated).delay(for: .seconds(2)) {
            
            completion([])
        }
    }
}
