//
//  QRScanResultMapperNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

struct QRScanResultMapperNanoServices {
    
    let getMapping: GetMapping
    let loadOperators: LoadOperators
    let loadProviders: LoadProviders
}

extension QRScanResultMapperNanoServices {
    
    typealias GetMapping = () -> QRMapping?
    
    typealias LoadOperators = (QRCode, QRMapping) -> [Operator]?
    typealias LoadProviders = (QRCode, QRMapping) -> [Provider]?
    
    typealias Operator = SegmentedOperatorData
    typealias Provider = SegmentedProvider
}
