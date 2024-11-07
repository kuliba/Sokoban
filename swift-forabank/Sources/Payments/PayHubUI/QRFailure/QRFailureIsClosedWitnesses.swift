//
//  QRFailureIsClosedWitnesses.swift
//
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine

public struct QRFailureIsClosedWitnesses<Categories, DetailPayment> {
    
    public let categories: CategoriesWitness
    public let detailPayment: DetailPaymentWitness
    
    public init(
        categories: @escaping CategoriesWitness,
        detailPayment: @escaping DetailPaymentWitness
    ) {
        self.categories = categories
        self.detailPayment = detailPayment
    }
    
    public typealias IsClosed<T> = (T) -> AnyPublisher<Bool, Never>
    public typealias CategoriesWitness = IsClosed<Categories>
    public typealias DetailPaymentWitness = IsClosed<DetailPayment>
}
