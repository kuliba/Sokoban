//
//  QRScanResultMapperComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.08.2024.
//

import ForaTools
import Foundation

final class QRScanResultMapperComposer {
    
    private let flag: Flag
    private let model: Model
    
    init(
        flag: Flag,
        model: Model
    ) {
        self.flag = flag
        self.model = model
    }
    
    typealias Flag = UtilitiesPaymentsFlag
}

extension QRScanResultMapperComposer {
    
    func compose() -> QRScanResultMapper {
        
        return .init(
            microServices: .init(
                getMapping: model.getMapping,
                getOperators: model.operatorsFromQR(_:_:_:)
            )
        )
    }
}

private extension Model {
    
    func getMapping() -> QRMapping? {
        
        return qrMapping.value
    }
    
    typealias LoadResult = OperatorProviderLoadResult<Operator, Provider>
    typealias Operator = SegmentedOperatorData
    typealias Provider = SegmentedProvider
    
    // TODO: add fallback to remote
    func operatorsFromQR(
        _ qr: QRCode,
        _ qrMapping: QRMapping,
        _ completion: @escaping (LoadResult) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self else { return }
            
            let operators = segmentedFromDictionary(qr, qrMapping)
            let providers = segmentedFromCache(qr, qrMapping)
            
            completion(.init(operators: operators, providers: providers))
        }
    }
    
    func segmentedFromDictionary(
        _ qrCode: QRCode,
        _ qrMapping: QRMapping
    ) -> [SegmentedOperatorData]? {
        
        return operatorsFromQR(qrCode, qrMapping)?
            .filter(\.isGroup)
            .compactMap {
                
                return .init(data: $0, segment: serviceName(for: $0))
            }
    }
    
    private func segmentedFromCache(
        _ qrCode: QRCode,
        _ qrMapping: QRMapping
    ) -> [SegmentedProvider]? {
        
        guard let inn = qrCode.stringValue(type: .general(.inn), mapping: qrMapping)
        else { return nil }
        
        return segmentedFromCache(with: inn)
    }
    
    // TODO: replace with loader with fallback to remote
    private func segmentedFromCache(
        with inn: String
    ) -> [SegmentedProvider]? {
        
        localAgent.load(type: [CachingSberOperator].self)?
            .filter { $0.inn == inn }
            .map(SegmentedProvider.init)
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

private extension SegmentedOperatorData {
    
    init?(
        data: OperatorGroupData.OperatorData,
        segment: String?
    ) {
        guard let segment else { return nil }
        
        self.init(data: data, segment: segment)
    }
}

private extension SegmentedProvider {
    
    init(
        with cached: CachingSberOperator
    ) {
        // TODO: add `segment` property to `CachingSberOperator`
        let segment = PTSectionPaymentsView.ViewModel.PaymentsType.service
        
        self.init(
            origin: .init(
                id: cached.id,
                icon: cached.md5Hash,
                inn: cached.inn,
                title: cached.title,
                segment: segment.apearance.title
            ),
            segment: segment.apearance.title
        )
    }
}
