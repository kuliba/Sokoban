//
//  QRBinderGetNavigationWitnesses.swift
//  
//
//  Created by Igor Malyarov on 30.10.2024.
//

import Combine

public struct QRBinderGetNavigationWitnesses<MixedPicker, Payments, QRFailure> {
    
    public let isClosed: (Payments) -> AnyPublisher<Bool, Never>
    public let mixedPickerIsClosed: (MixedPicker) -> AnyPublisher<Bool, Never>
    public let mixedPickerScanQR: ScanQR<MixedPicker>
    public let scanQR: ScanQR<Payments>
    public let qrFailureScanQR: ScanQR<QRFailure>
    
    public init(
        isClosed: @escaping (Payments) -> AnyPublisher<Bool, Never>,
        mixedPickerIsClosed: @escaping (MixedPicker) -> AnyPublisher<Bool, Never>,
        mixedPickerScanQR: @escaping ScanQR<MixedPicker>,
        scanQR: @escaping ScanQR<Payments>,
        qrFailureScanQR: @escaping ScanQR<QRFailure>
    ) {
        self.isClosed = isClosed
        self.mixedPickerIsClosed = mixedPickerIsClosed
        self.mixedPickerScanQR = mixedPickerScanQR
        self.scanQR = scanQR
        self.qrFailureScanQR = qrFailureScanQR
    }
    
    public typealias ScanQR<T> = (T) -> AnyPublisher<Void, Never>
}
