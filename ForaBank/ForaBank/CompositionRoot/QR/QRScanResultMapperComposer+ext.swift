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
                loadOperators: {
                    
                    switch flag.rawValue {
                    case .active:
                        return model.segmentedFromDictionary($0, $1)?
                            .filter(\.isNotSberProvider)
                        
                    case .inactive:
                        return model.segmentedFromDictionary($0, $1)
                    }
                    
                },
                loadProviders: {
                    
                    switch flag.rawValue {
                    case .active(.live):
                        return model.segmentedFromCache($0, $1)
                        
                    case .active(.stub):
                        // stub()
                        return model.segmentedFromCache($0, $1)
                        
                    case .inactive:
                        return nil
                    }
                }
            )
        )
    }
}

private extension SegmentedOperatorData {
    
    var isNotSberProvider: Bool {
        
        origin.parentCode != "iFora||1031001"
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
        
        localAgent.load(type: [CachingSberOperator].self)?
            .filter { $0.inn == inn }
            .map(SegmentedProvider.init)
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
