//
//  Model+QRHelpers.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.12.2023.
//

// MARK: - Reusable

extension Model {
    
    func operatorsFromQR(
        _ qr: QRCode,
        _ qrMapping: QRMapping
    ) -> [OperatorGroupData.OperatorData]? {
        
        guard let operatorsFromQr = dictionaryAnywayOperators(
            with: qr,
            mapping: qrMapping
        )
        else { return nil }
        
        let validQrOperators = dictionaryQRAnewayOperator()
        let operators = operatorsFromQr.filter {
            
            validQrOperators.contains($0) && !$0.parameterList.isEmpty
        }
        
        return operators
    }
    
    func segmentedPaymentProviders(
        matching qrCode: QRCode,
        qrMapping: QRMapping
    ) -> [SegmentedPaymentProvider]? {
        
        let cached = loadCached(matching: qrCode, qrMapping: qrMapping)
        let anyway = segmentedFromDictionary(matching: qrCode, qrMapping: qrMapping)
        
        switch (cached, anyway) {
        case (.none, .none):
            return .none
            
        case let (.none, .some(anyway)):
            return anyway
            
        case let (.some(cached), .none):
            return cached
            
        case let (.some(cached), .some(anyway)):
            return cached + anyway
        }
    }
    
    func segmentedFromDictionary(
        matching qrCode: QRCode,
        qrMapping: QRMapping
    ) -> [SegmentedPaymentProvider]? {
        
        return operatorsFromQR(qrCode, qrMapping)?
            .filter(\.isGroup)
            .compactMap {
                
                SegmentedPaymentProvider(with: $0, segment: serviceName(for: $0))
            }
    }
    
    func loadCached(
        matching code: QRCode,
        qrMapping: QRMapping
    ) -> [SegmentedPaymentProvider]? {
        
        guard let inn = code.stringValue(type: .general(.inn), mapping: qrMapping)
        else { return nil }
        
        return loadCached(with: inn)
    }
    
    func loadCached(
        with inn: String
    ) -> [SegmentedPaymentProvider]? {
        
        // TODO: replace with loader with fallback to remote
        // TODO: expensive! make async with QOS
        localAgent.load(type: [CachingSberOperator].self)?
            .filter { $0.inn == inn }
            .map(SegmentedPaymentProvider.init)
    }
}

private extension SegmentedPaymentProvider {
    
    init?(
        with data: OperatorGroupData.OperatorData,
        segment: String?
    ) {
        guard let segment else { return nil }
        
        self.init(
            id: data.code,
            icon: data.logotypeList.first?.svgImage?.description,
            inn: data.synonymList.first,
            title: data.title,
            segment: segment
        )
    }
    
    init(with `operator`: CachingSberOperator) {
        
        // TODO: add `segment` property to `CachingSberOperator`
        let segment = PTSectionPaymentsView.ViewModel.PaymentsType.service
        
        self.init(
            id: `operator`.id,
            icon: `operator`.md5Hash,
            inn: `operator`.inn,
            title: `operator`.title,
            segment: segment.apearance.title
        )
    }
}
