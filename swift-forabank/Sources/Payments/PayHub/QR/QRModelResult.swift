//
//  QRModelResult.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import ForaTools
import Foundation

public enum QRModelResult<Operator, Provider, QRCode, QRMapping, Source> {
    
    case c2bSubscribeURL(URL)
    case c2bURL(URL)
    case failure(QRCode)
    case mapped(Mapped)
    case sberQR(URL)
    case url(URL)
    case unknown
    
    public enum Mapped {
        
        case missingINN(QRCode)
        case mixed(Mixed)
        case multiple(Multiple)
        case none(QRCode)
        case provider(ProviderPayload<Provider, QRCode, QRMapping>)
        case single(Operator, QRCode, QRMapping)
        case source(Source) // Payments.Operation.Source

        public typealias Mixed = MixedQRResult<Operator, Provider, QRCode, QRMapping>
        public typealias Multiple = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    }
}

extension QRModelResult: Equatable where Operator: Equatable, Provider: Equatable, QRCode: Equatable, QRMapping: Equatable, Source: Equatable {}
extension QRModelResult.Mapped: Equatable where Operator: Equatable, Provider: Equatable, QRCode: Equatable, QRMapping: Equatable, Source: Equatable {}

public enum OperatorProvider<Operator, Provider> {
    
    case `operator`(Operator)
    case provider(Provider)
}

extension OperatorProvider: Equatable where Operator: Equatable, Provider: Equatable {}

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
