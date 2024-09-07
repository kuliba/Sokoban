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
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        #warning("replace stub with implementation")
        DispatchQueue.global(qos: .userInitiated).delay(for: .seconds(2)) {
            
            completion(.success([]))
        }
    }
    
    static func getLatestPayments(
        category: ServiceCategory,
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        getLatestPayments(categories: [category], completion: completion)
    }
    
    @available(*, deprecated, message: "Use `static NanoServices.getLatestPayments(categories:completion:)` with strong API after hard-code for `isOutsidePayments` and `isPhonePayments` deprecation")
    static func getLatestPayments(
        categoryNames: [String],
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        #warning("replace stub with implementation")
        DispatchQueue.global(qos: .userInitiated).delay(for: .seconds(2)) {
            
            completion(.success([]))
        }
    }
    
    @available(*, deprecated, message: "Use `static NanoServices.getLatestPayments(category:completion:)` with strong API after hard-code for `isOutsidePayments` and `isPhonePayments` deprecation")
    static func getLatestPayments(
        categoryName category: String,
        completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        getLatestPayments(categoryNames: [category], completion: completion)
    }
}
