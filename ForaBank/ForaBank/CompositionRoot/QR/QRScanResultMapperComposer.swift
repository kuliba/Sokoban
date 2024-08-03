//
//  QRScanResultMapperComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.08.2024.
//

import ForaTools
import Foundation

final class QRScanResultMapperComposer {
    
    private let nanoServices: NanoServices
    
    init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = QRScanResultMapperNanoServices
}

extension QRScanResultMapperComposer {
    
    func compose() -> QRScanResultMapper {
        
        return .init(
            microServices: .init(
                getMapping: getMapping,
                getOperators: operatorsFromQR(_:_:_:)
            )
        )
    }
}

private extension QRScanResultMapperComposer {
    
    func getMapping() -> QRMapping? {
        
        return nanoServices.getMapping()
    }
    
    typealias LoadResult = OperatorProviderLoadResult<Operator, Provider>
    typealias Operator = SegmentedOperatorData
    typealias Provider = SegmentedProvider
    
    // TODO: add fallback to remote
    func operatorsFromQR(
        _ qrCode: QRCode,
        _ qrMapping: QRMapping,
        _ completion: @escaping (LoadResult) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self else { return }
            
            let operators = nanoServices.loadOperators(qrCode, qrMapping)
            let providers = nanoServices.loadProviders(qrCode, qrMapping)
            
            completion(.init(operators: operators, providers: providers))
        }
    }
}

private extension OperatorProviderLoadResult {
    
    init(
        operators: [Operator]?,
        providers: [Provider]?
    ) {
        self.init(
            operators: operators ?? [],
            providers: providers ?? []
        )
    }
}
