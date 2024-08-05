//
//  QRScanResultMapperComposer+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

extension QRScanResultMapperComposer {
    
    convenience init(
        flag: UtilitiesPaymentsFlag,
        model: Model
    ) {
        self.init(
            nanoServices: .init(
                getMapping: model.getMapping,
                loadOperators: model.segmentedFromDictionary,
                loadProviders: {
                    
                    switch flag.rawValue {
                    case .active(.live):
                        return model.segmentedFromCache($0, $1)
                        
                    case .active(.stub):
                        return nil // stub()
                        
                    case .inactive:
                        return nil
                    }
                }
            )
        )
    }
}

private extension Model {
    
    func getMapping() -> QRMapping? {
        
        return qrMapping.value
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
    
    func segmentedFromCache(
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
