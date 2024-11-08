//
//  MixedQRResult.swift
//
//
//  Created by Igor Malyarov on 07.11.2024.
//

import ForaTools

public struct MixedQRResult<Operator, Provider, QRCode, QRMapping> {
    
    public let operators: MixedOperators
    public let qrCode: QRCode
    public let qrMapping: QRMapping
    
    public init(
        operators: MixedOperators,
        qrCode: QRCode,
        qrMapping: QRMapping
    ) {
        self.operators = operators
        self.qrCode = qrCode
        self.qrMapping = qrMapping
    }
    
    public typealias MixedOperators = MultiElementArray<OperatorProvider<Operator, Provider>>
}

extension MixedQRResult: Equatable where Operator: Equatable, Provider: Equatable, QRCode: Equatable, QRMapping: Equatable {}
