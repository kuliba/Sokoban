//
//  QRScanResultHandler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import ForaTools
import Foundation

final class QRScanResultHandler {
    
    private let getMapping: GetMapping
    private let getOperators: GetOperators
    private let mapSingle: MapSingle
    
    init(
        getMapping: @escaping GetMapping,
        getOperators: @escaping GetOperators,
        mapSingle: @escaping MapSingle
    ) {
        self.getMapping = getMapping
        self.getOperators = getOperators
        self.mapSingle = mapSingle
    }
    
    typealias GetMapping = () -> QRMapping?
    typealias GetOperators = (QRCode, QRMapping, @escaping (OperatorProviderLoadResult<Operator, Provider>) -> Void) -> Void
    typealias MapSingle = (OperatorGroupData.OperatorData, QRCode, QRMapping) -> QRModelResult.Mapped
    
    typealias Operator = OperatorGroupData.OperatorData
    typealias Provider = PaymentProvider
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
        getOperators(qr, qrMapping) { [weak self] loadResult in
            
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
