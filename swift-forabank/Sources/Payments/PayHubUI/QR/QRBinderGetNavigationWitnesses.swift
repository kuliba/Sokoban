//
//  QRBinderGetNavigationWitnesses.swift
//
//
//  Created by Igor Malyarov on 30.10.2024.
//

import Combine

public struct QRBinderGetNavigationWitnesses<MixedPicker, Payments, QRFailure> {
    
    public let mixedPicker: MixedPickerWitness
    public let payments: PaymentsWitness
    public let qrFailure: QRFailureWitness
    
    public init(
        mixedPicker: MixedPickerWitness,
        payments: PaymentsWitness,
        qrFailure: QRFailureWitness
    ) {
        self.mixedPicker = mixedPicker
        self.payments = payments
        self.qrFailure = qrFailure
    }
    
    public typealias MixedPickerWitness = ClosingScanQRWitnesses<MixedPicker>
    public typealias PaymentsWitness = ClosingScanQRWitnesses<Payments>
    public typealias QRFailureWitness = ClosingScanQRWitnesses<QRFailure>
    
    public struct ClosingScanQRWitnesses<T> {
        
        public let isClosed: MakeIsClosedPublisher<T>
        public let scanQR: MakeScanQRPublisher<T>
        
        public init(
            isClosed: @escaping MakeIsClosedPublisher<T>,
            scanQR: @escaping MakeScanQRPublisher<T>
        ) {
            self.isClosed = isClosed
            self.scanQR = scanQR
        }
        
        public typealias MakeIsClosedPublisher<V> = (V) -> AnyPublisher<Bool, Never>
        public typealias MakeScanQRPublisher<V> = (V) -> AnyPublisher<Void, Never>
    }
}
