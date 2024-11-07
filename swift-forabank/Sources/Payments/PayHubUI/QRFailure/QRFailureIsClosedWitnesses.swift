//
//  QRFailureIsClosedWitnesses.swift
//
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine

public struct QRFailureIsClosedWitnesses<CategoryPicker, DetailPayment> {
    
    public let categoryPicker: CategoryPickerWitness
    public let detailPayment: DetailPaymentWitness
    
    public init(
        categoryPicker: @escaping CategoryPickerWitness,
        detailPayment: @escaping DetailPaymentWitness
    ) {
        self.categoryPicker = categoryPicker
        self.detailPayment = detailPayment
    }
    
    public typealias IsClosed<T> = (T) -> AnyPublisher<Bool, Never>
    public typealias CategoryPickerWitness = IsClosed<CategoryPicker>
    public typealias DetailPaymentWitness = IsClosed<DetailPayment>
}
