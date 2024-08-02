//
//  QRScanResultHandlerComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.08.2024.
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
            getMapping: model.getMapping,
            getOperators: model.operatorsFromQR(_:_:_:),
            mapSingle: model.mapSingle(_:_:_:)
        )
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
    
    typealias Operator = OperatorGroupData.OperatorData
    typealias Provider = PaymentProvider
    
    func operatorsFromQR(
        _ qr: QRCode,
        _ qrMapping: QRMapping,
        _ completion: @escaping (LoadResult<Operator, Provider>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self else { return }
            
            let operators = operatorsFromQR(qr, qrMapping) ?? []
            let providers: [PaymentProvider] = [.init(id: "1", type: .service)]//{ fatalError() }()
            
            completion(.init(operators: operators, providers: providers))
        }
    }
}
