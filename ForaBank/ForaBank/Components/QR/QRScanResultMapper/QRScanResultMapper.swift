//
//  QRScanResultMapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import ForaTools
import Foundation

final class QRScanResultMapper {
    
    private let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = QRScanResultMapperMicroServices
}

extension QRScanResultMapper {
    
    func mapScanResult(
        _ scanResult: QRViewModel.ScanResult,
        _ completion: @escaping (QRModelResult) -> Void
    ) {
        let qrModelResult: QRModelResult
        
        switch scanResult {
        case let .qrCode(qrCode):
            if let qrMapping = microServices.getMapping() {
                return resolveMapped(qrCode, qrMapping) { completion(.mapped($0)) }
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

private extension QRScanResultMapper {
    
    func resolveMapped(
        _ qr: QRCode,
        _ qrMapping: QRMapping,
        _ completion: @escaping (QRModelResult.Mapped) -> Void
    ) {
        microServices.getOperators(qr, qrMapping) { [weak self] loadResult in
            
            guard let self else { return }
            
            switch loadResult {
            case let .mixed(mixed):
                completion(.mixed(mixed, qr))
                
            case let .multiple(multipleOperators):
                completion(.multiple(multipleOperators, qr))
                
            case .none:
                completion(.none(qr))
                
            case let .operator(`operator`):
                completion(`operator`.match(qr, qrMapping: qrMapping))
                
            case let .provider(provider):
                handleSingle(provider, qr, qrMapping, completion)
            }
        }
    }
    
    private func handleSingle(
        _ provider: SegmentedProvider,
        _ qr: QRCode,
        _ qrMapping: QRMapping,
        _ completion: @escaping (QRModelResult.Mapped) -> Void
    ) {
        // найден 1 поставщик и type = housingAndCommunalService
        completion(.provider(provider))
    }
}

private extension SegmentedOperatorData {
    
    func match(
        _ qrCode: QRCode,
        qrMapping: QRMapping
    ) -> QRModelResult.Mapped {
        
        guard let source = origin.serviceSource(matching: qrCode)
        else { return .single(qrCode, qrMapping) }
        
        return .source(source)
    }
}

private extension OperatorGroupData.OperatorData {
    
    func serviceSource(
        matching qrCode: QRCode
    ) -> Payments.Operation.Source? {
        
        guard isServicePayment else { return nil }
        
        let puref = code
        let additionalList = getAdditionalList(matching: qrCode)
        let amount = qrCode.rawData["sum"]?.toDouble() ?? 0
        
        return .servicePayment(
            puref: puref,
            additionalList: additionalList,
            amount: amount/100
        )
    }
    
    private var isServicePayment: Bool {
        
        return Payments
            .paymentsServicesOperators
            .map(\.rawValue)
            .contains(parentCode)
    }
}
