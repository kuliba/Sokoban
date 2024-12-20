//
//  QRFailureScanQRWitnesses.swift
//  
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine

public struct QRFailureScanQRWitnesses<CategoryPicker, DetailPayment> {
    
    public let categoryPicker: CategoryPickerWitness
    public let detailPayment: DetailPaymentWitness
    
    public init(
        categoryPicker: @escaping CategoryPickerWitness,
        detailPayment: @escaping DetailPaymentWitness
    ) {
        self.categoryPicker = categoryPicker
        self.detailPayment = detailPayment
    }
    
    public typealias CategoryPickerWitness = (CategoryPicker) -> AnyPublisher<Void, Never>
    public typealias DetailPaymentWitness = (DetailPayment) -> AnyPublisher<Void, Never>
}
