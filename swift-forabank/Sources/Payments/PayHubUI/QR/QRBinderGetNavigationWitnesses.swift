//
//  QRBinderGetNavigationWitnesses.swift
//  
//
//  Created by Igor Malyarov on 30.10.2024.
//

import Combine

public struct QRBinderGetNavigationWitnesses<Payments> {
    
    public let isClosed: (Payments) -> AnyPublisher<Bool, Never>
    public let scanQR: (Payments) -> AnyPublisher<Void, Never>
    
    public init(
        isClosed: @escaping (Payments) -> AnyPublisher<Bool, Never>,
        scanQR: @escaping (Payments) -> AnyPublisher<Void, Never>
    ) {
        self.isClosed = isClosed
        self.scanQR = scanQR
    }
}
