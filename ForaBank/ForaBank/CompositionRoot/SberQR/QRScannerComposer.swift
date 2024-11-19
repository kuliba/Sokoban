//
//  QRScannerComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.10.2024.
//

import CombineSchedulers
import Foundation

final class QRScannerComposer {
    
    let model: Model
    let qrResolverFeatureFlag: QRResolverFeatureFlag
    let utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.qrResolverFeatureFlag = qrResolverFeatureFlag
        self.utilitiesPaymentsFlag = utilitiesPaymentsFlag
        self.scheduler = scheduler
    }
}

extension QRScannerComposer {
    
    func compose() -> QRScannerModel {
        
        // TODO: make async and move all QR mapping from QRViewModel to special new QRResolver component
        let qrResolve: QRViewModel.QRResolve = { [self] string in
            
            let isSberQR = qrResolverFeatureFlag.isActive ? self.model.isSberQR : { _ in false }
            let resolver = QRResolver(isSberQR: isSberQR)
            
            return resolver.resolve(string: string)
        }
        
        let composer = QRScanResultMapperComposer(
            flag: utilitiesPaymentsFlag,
            model: model
        )
        let mapper = composer.compose()
        
        return .init(
            mapScanResult: mapper.mapScanResult(_:_:),
            makeQRModel: { .init(closeAction: $0, qrResolve: qrResolve) },
            scheduler: scheduler
        )
    }
}
