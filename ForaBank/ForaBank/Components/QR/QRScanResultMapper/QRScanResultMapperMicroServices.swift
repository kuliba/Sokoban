//
//  QRScanResultMapperMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.08.2024.
//

struct QRScanResultMapperMicroServices {
    
    let getMapping: GetMapping
    let getOperators: GetOperators
    let mapSingle: MapSingle
    
    typealias GetMapping = () -> QRMapping?
    typealias LoadResult = OperatorProviderLoadResult<Operator, Provider>
    typealias GetOperators = (QRCode, QRMapping, @escaping (LoadResult) -> Void) -> Void
    typealias MapSingle = (SegmentedOperatorData, QRCode, QRMapping) -> QRModelResult.Mapped
    
    typealias Operator = SegmentedOperatorData
    typealias Provider = SegmentedProvider
}
