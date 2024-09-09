//
//  NanoServices+getLatestPayments.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import Foundation
import LatestPaymentsBackendV3
import RemoteServices

extension NanoServices {
    
    typealias GetAllLatestPaymentsCompletion = (Result<[Latest], Error>) -> Void
        
    static func getLatestPayments(
        categories: [ServiceCategory],
        completion: @escaping GetAllLatestPaymentsCompletion
    ) {
        #warning("replace stub with implementation")
        DispatchQueue.global(qos: .userInitiated).delay(for: .seconds(2)) {
            
            completion(.success([]))
        }
    }
    
    static func getLatestPayments(
        category: ServiceCategory,
        completion: @escaping GetAllLatestPaymentsCompletion
    ) {
        getLatestPayments(categories: [category], completion: completion)
    }
    
    // MARK: - Stringly API
    // see deprecation warnings for details
    
    @available(*, deprecated, message: "Use `static NanoServices.getLatestPayments(categories:completion:)` with strong API after hard-code for `isOutsidePayments` and `isPhonePayments` deprecation")
    static func getLatestPayments(
        categoryNames: [String],
        completion: @escaping GetAllLatestPaymentsCompletion
    ) {
        #warning("replace stub with implementation")
        DispatchQueue.global(qos: .userInitiated).delay(for: .seconds(2)) {
            
            completion(.success([]))
        }
    }
    
    @available(*, deprecated, message: "Use `static NanoServices.getLatestPayments(category:completion:)` with strong API after hard-code for `isOutsidePayments` and `isPhonePayments` deprecation")
    static func getLatestPayments(
        categoryName category: String,
        completion: @escaping GetAllLatestPaymentsCompletion
    ) {
        getLatestPayments(categoryNames: [category], completion: completion)
    }
}
