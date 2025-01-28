//
//  QRScanResultMapperComposer+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.08.2024.
//

extension QRScanResultMapperComposer {
    
    convenience init(
        model: Model
    ) {
        self.init(
            nanoServices: .init(
                getMapping: model.getMapping,
                loadOperators: {
                    
                    return model.segmentedFromDictionary($0, $1)?
                        .filter(\.isNotSberProvider)
                },
                loadProviders: {
                    
                    return model.segmentedFromCache($0, $1)
                }
            )
        )
    }
}

private extension SegmentedOperatorData {
    
    var isNotSberProvider: Bool {
        
        origin.parentCode != "\(Config.puref)||1031001"
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
        
        guard let operators = operatorsFromQR(qrCode, qrMapping)
        else { return nil }
        
        let mapped: [SegmentedOperatorData] = operators
            .compactMap { data -> SegmentedOperatorData? in
                
                guard let segment = serviceName(for: data) else { return nil }
                
                return .init(origin: data, segment: segment)
            }
        
        return mapped
    }
    
    func segmentedFromCache(
        _ qrCode: QRCode,
        _ qrMapping: QRMapping
    ) -> [SegmentedProvider]? {
        
        guard let inn = qrCode.stringValue(type: .general(.inn), mapping: qrMapping)
        else { return nil }
        
        let cached = segmentedFromCache(with: inn)
        
        return cached
    }
    
    // TODO: replace with loader with fallback to remote
    private func segmentedFromCache(
        with inn: String
    ) -> [SegmentedProvider]? {
        
        localAgent.load(type: ServicePaymentOperatorStorage.self)?
            .search(for: inn, in: \.inn)
            .map(SegmentedProvider.init)
    }
}

private extension SegmentedProvider {
    
    init(
        with cached: CodableServicePaymentOperator
    ) {
        // TODO: add `segment` property to `CachingSberOperator`
        let segment = PTSectionPaymentsView.ViewModel.PaymentsType.service
        
        self.init(
            origin: .init(
                id: cached.id,
                icon: cached.md5Hash,
                inn: cached.inn,
                title: cached.name,
                type: cached.type
            ),
            segment: segment.apearance.title
        )
    }
}
