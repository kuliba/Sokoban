//
//  QRBinderGetNavigationWitnesses.swift
//
//
//  Created by Igor Malyarov on 30.10.2024.
//

import Combine

public struct QRBinderGetNavigationWitnesses<MixedPicker, MultiplePicker, Payments, QRFailure> {
    
    public let addCompany: AddCompanyWitnesses
    public let isClosed: IsClosedWitnesses
    public let scanQR: ScanQRWitnesses
    
    public init(
        addCompany: AddCompanyWitnesses,
        isClosed: IsClosedWitnesses,
        scanQR: ScanQRWitnesses
    ) {
        self.addCompany = addCompany
        self.isClosed = isClosed
        self.scanQR = scanQR
    }
    
    public struct AddCompanyWitnesses {
        
        public let mixedPicker: MakeAddCompanyPublisher<MixedPicker>
        public let multiplePicker: MakeAddCompanyPublisher<MultiplePicker>
        
        public init(
            mixedPicker: @escaping MakeAddCompanyPublisher<MixedPicker>,
            multiplePicker: @escaping MakeAddCompanyPublisher<MultiplePicker>
        ) {
            self.mixedPicker = mixedPicker
            self.multiplePicker = multiplePicker
        }
        
        public typealias MakeAddCompanyPublisher<V> = (V) -> AnyPublisher<Void, Never>
    }
    
    public typealias IsClosedWitnesses = Witness<Bool>
    public typealias ScanQRWitnesses = Witness<Void>
    
    public struct Witness<Value> {
        
        public let mixedPicker: MakePublisher<MixedPicker>
        public let multiplePicker: MakePublisher<MultiplePicker>
        public let payments: MakePublisher<Payments>
        public let qrFailure: MakePublisher<QRFailure>
        
        public init(
            mixedPicker: @escaping MakePublisher<MixedPicker>,
            multiplePicker: @escaping MakePublisher<MultiplePicker>,
            payments: @escaping MakePublisher<Payments>,
            qrFailure: @escaping MakePublisher<QRFailure>
        ) {
            self.mixedPicker = mixedPicker
            self.multiplePicker = multiplePicker
            self.payments = payments
            self.qrFailure = qrFailure
        }
        
        public typealias MakePublisher<V> = (V) -> AnyPublisher<Value, Never>
    }
}
