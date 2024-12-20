//
//  MultipleQRResult.swift
//
//
//  Created by Igor Malyarov on 07.11.2024.
//

import VortexTools

public struct MultipleQRResult<Operator, Provider, QRCode, QRMapping> {
    
    public let operators: MultipleOperators
    public let qrCode: QRCode
    public let qrMapping: QRMapping
    
    public init(
        operators: MultipleOperators, 
        qrCode: QRCode,
        qrMapping: QRMapping
    ) {
        self.operators = operators
        self.qrCode = qrCode
        self.qrMapping = qrMapping
    }
    
    public typealias MultipleOperators = MultiElementArray<Operator>
}

extension MultipleQRResult: Equatable where Operator: Equatable, Provider: Equatable, QRCode: Equatable, QRMapping: Equatable {}
