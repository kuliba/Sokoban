//
//  ProviderPayload.swift
//  
//
//  Created by Igor Malyarov on 08.11.2024.
//

// PaymentProviderServicePickerPayload
public struct ProviderPayload<Provider, QRCode, QRMapping> {
    
    public let provider: Provider
    public let qrCode: QRCode
    public let qrMapping: QRMapping
    
    public init(
        provider: Provider,
        qrCode: QRCode,
        qrMapping: QRMapping
    ) {
        self.provider = provider
        self.qrCode = qrCode
        self.qrMapping = qrMapping
    }
}

extension ProviderPayload: Equatable where Provider: Equatable, QRCode: Equatable, QRMapping: Equatable {}
