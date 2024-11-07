//
//  QRFailureScanQRWitnesses.swift
//  
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine

public struct QRFailureScanQRWitnesses<DetailPayment> {
    
    public let detailPayment: DetailPaymentWitness
    
    public init(
        detailPayment: @escaping DetailPaymentWitness
    ) {
        self.detailPayment = detailPayment
    }
    
    public typealias DetailPaymentWitness = (DetailPayment) -> AnyPublisher<Void, Never>
}
