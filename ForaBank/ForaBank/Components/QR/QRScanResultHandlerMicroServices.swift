//
//  QRScanResultHandlerMicroServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.08.2024.
//

struct QRScanResultHandlerMicroServices {
    
    let getMapping: GetMapping
    let getOperators: GetOperators
    let mapSingle: MapSingle
    
    typealias GetMapping = () -> QRMapping?
    typealias LoadResult = OperatorProviderLoadResult<Operator, Provider>
    typealias GetOperators = (QRCode, QRMapping, @escaping (LoadResult) -> Void) -> Void
    typealias MapSingle = (OperatorGroupData.OperatorData, QRCode, QRMapping) -> QRModelResult.Mapped
    
    typealias Operator = OperatorGroupData.OperatorData
    typealias Provider = PaymentProvider
}
