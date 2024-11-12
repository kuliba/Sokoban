//
//  SinglePayload.swift
//
//
//  Created by Igor Malyarov on 09.11.2024.
//

public struct SinglePayload<Operator, QRCode, QRMapping> {
    
    public let `operator`: Operator
    public let qrCode: QRCode
    public let qrMapping: QRMapping
    
    public init(
        `operator`: Operator,
        qrCode: QRCode,
        qrMapping: QRMapping
    ) {
        self.`operator` = `operator`
        self.qrCode = qrCode
        self.qrMapping = qrMapping
    }
}

extension SinglePayload: Equatable where Operator: Equatable, QRCode: Equatable, QRMapping: Equatable {}
