//
//  QRScanResultHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import ForaTools
import Foundation

final class QRScanResultHandler {
    
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

extension QRScanResultHandler {
    
    func handleScanResult(
        _ scanResult: QRViewModel.ScanResult,
        _ completion: @escaping (QRModelResult) -> Void
    ) {
        let qrModelResult: QRModelResult
        
        switch model.mapScanResult(scanResult) {
        case let .mapped(qr, qrMapping):
            return handleMapped(qr, qrMapping) { completion(.mapped($0)) }
            
        case let .failure(failure):
            qrModelResult = .failure(failure)
            
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
                completion(model.mapSingle(`operator`, qr, qrMapping))
                
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
    
    typealias PaymentOperator = OperatorProvider<Operator, Provider>
    
    typealias Operator = OperatorGroupData.OperatorData
    typealias Provider = PaymentProvider
    
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
    
    enum _QRModelResult: Equatable {
        
        case mapped(QRCode, QRMapping)
        case failure(QRCode)
        case c2bURL(URL)
        case c2bSubscribeURL(URL)
        case sberQR(URL)
        case url(URL)
        case unknown
    }
    
    func mapScanResult(
        _ result: QRViewModel.ScanResult
    ) -> _QRModelResult {
        
        switch result {
        case let .qrCode(qrCode):
            if let qrMapping = qrMapping.value {
                return .mapped(qrCode, qrMapping)
            } else {
                return .failure(qrCode)
            }
            
        case let .c2bURL(c2bURL):
            return .c2bURL(c2bURL)
            
        case let .c2bSubscribeURL(c2bSubscribeURL):
            return .c2bSubscribeURL(c2bSubscribeURL)
            
        case let .sberQR(sberQR):
            return .sberQR(sberQR)
            
        case let .url(url):
            return .url(url)
            
        case .unknown:
            return .unknown
        }
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
