//
//  QRScanResultHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import ForaTools
import Foundation

final class QRScanResultHandlerComposer {
    
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

extension QRScanResultHandlerComposer {
    
    func compose() -> QRScanResultHandler {
        
        return .init(
            flag: flag,
            getMapping: model.getMapping,
            mapSingle: model.mapSingle(_:_:_:),
            model: model
        )
    }
}

final class QRScanResultHandler {
    
    private let flag: Flag
    private let getMapping: GetMapping
    private let mapSingle: MapSingle
    private let model: Model
    
    init(
        flag: Flag,
        getMapping: @escaping GetMapping,
        mapSingle: @escaping MapSingle,
        model: Model
    ) {
        self.flag = flag
        self.getMapping = getMapping
        self.mapSingle = mapSingle
        self.model = model
    }
    
    typealias Flag = UtilitiesPaymentsFlag
    typealias GetMapping = () -> QRMapping?
    typealias MapSingle = (OperatorGroupData.OperatorData, QRCode, QRMapping) -> QRModelResult.Mapped
}

extension QRScanResultHandler {
    
    func handleScanResult(
        _ scanResult: QRViewModel.ScanResult,
        _ completion: @escaping (QRModelResult) -> Void
    ) {
        let qrModelResult: QRModelResult
        
        switch scanResult {
        case let .qrCode(qrCode):
            if let qrMapping = getMapping() {
                return handleMapped(qrCode, qrMapping) { completion(.mapped($0)) }
            } else {
                qrModelResult = .failure(qrCode)
            }
            
        case let .c2bURL(c2bURL):
            qrModelResult = .c2bURL(c2bURL)
            
        case let .c2bSubscribeURL(c2bSubscribeURL):
            qrModelResult = .c2bSubscribeURL(c2bSubscribeURL)
            
        case let .sberQR(sberQR):
            qrModelResult = .sberQR(sberQR)
            
        case let .url(url):
            qrModelResult = .url(url)
            
        case .unknown:
            qrModelResult = .unknown
        }
        
        completion(qrModelResult)
    }
}

private extension QRScanResultHandler {
    
    func handleMapped(
        _ qr: QRCode,
        _ qrMapping: QRMapping,
        _ completion: @escaping (QRModelResult.Mapped) -> Void
    ) {
        operatorsFromQR(qr, qrMapping) { [weak self] loadResult in
            
            guard let self else { return }
            
            switch loadResult {
            case let .mixed(mixed):
                completion(.mixed(mixed, qr))
                
            case let .multiple(multipleOperators):
                completion(.multiple(multipleOperators, qr))
                
            case .none:
                completion(.none(qr))
                
            case let .operator(`operator`):
                completion(mapSingle(`operator`, qr, qrMapping))
                
            case let .provider(provider):
                handleSingle(provider, qr, qrMapping, completion)
            }
        }
    }
    
    private func operatorsFromQR(
        _ qr: QRCode,
        _ qrMapping: QRMapping,
        _ completion: @escaping (LoadResult<Operator, Provider>) -> Void
    ) {
        let operators = model.operatorsFromQR(qr, qrMapping) ?? []
        let providers: [PaymentProvider] = [.init(id: "1", type: .service)]//{ fatalError() }()
        
        completion(.init(operators: operators, providers: providers))
    }
    
    private typealias Operator = OperatorGroupData.OperatorData
    private typealias Provider = PaymentProvider
    
    private func handleSingle(
        _ provider: Provider,
        _ qr: QRCode,
        _ qrMapping: QRMapping,
        _ completion: @escaping (QRModelResult.Mapped) -> Void
    ) {
        switch provider.type {
            // найден 1 поставщик и type = housingAndCommunalService
        case .service:
            completion(.provider(provider))
        }
    }
}

private extension Model {
    
    func getMapping() -> QRMapping? {
        
        return qrMapping.value
    }
    
    func mapSingle(
        _ `operator`: OperatorGroupData.OperatorData,
        _ qr: QRCode,
        _ qrMapping: QRMapping
    ) -> QRModelResult.Mapped {
        
        let isServicePayment = Payments
            .paymentsServicesOperators
            .map(\.rawValue)
            .contains(`operator`.parentCode)
        
        if isServicePayment {
            let puref = `operator`.code
            let additionalList = additionalList(for: `operator`, qrCode: qr)
            let amount: Double = qr.rawData["sum"]?.toDouble() ?? 0
            
            return .source(.servicePayment(
                puref: puref,
                additionalList: additionalList,
                amount: amount/100
            ))
        } else {
            return .single(qr, qrMapping)
        }
    }
}
