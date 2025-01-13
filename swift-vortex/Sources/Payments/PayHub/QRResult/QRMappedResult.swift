//
//  QRMappedResult.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import VortexTools
import Foundation

public enum QRMappedResult<Operator, Provider, QRCode, QRMapping, Source> {
    
    case missingINN(QRCode)
    case mixed(Mixed)
    case multiple(Multiple)
    case none(QRCode)
    case provider(ProviderPayload<Provider, QRCode, QRMapping>)
    case single(Single)
    case source(Source) // Payments.Operation.Source
    
    public typealias Mixed = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    public typealias Multiple = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    public typealias Single = SinglePayload<Operator, QRCode, QRMapping>
}

extension QRMappedResult: Equatable where Operator: Equatable, Provider: Equatable, QRCode: Equatable, QRMapping: Equatable, Source: Equatable {}
