//
//  QRFailureScanQRWitnesses.swift
//  
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine

public struct QRFailureScanQRWitnesses<Categories, DetailPayment> {
    
    public let categories: CategoriesWitness
    public let detailPayment: DetailPaymentWitness
    
    public init(
        categories: @escaping CategoriesWitness,
        detailPayment: @escaping DetailPaymentWitness
    ) {
        self.categories = categories
        self.detailPayment = detailPayment
    }
    
    public typealias CategoriesWitness = (Categories) -> AnyPublisher<Void, Never>
    public typealias DetailPaymentWitness = (DetailPayment) -> AnyPublisher<Void, Never>
}
