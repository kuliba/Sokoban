//
//  RootViewModelFactory+makeMakeQRScannerModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    static func makeMakeQRScannerModel(
        model: Model,
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> MakeQRScannerModel {
        
        // TODO: make async and move all QR mapping from QRViewModel to special new QRResolver component
        let qrResolve: QRViewModel.QRResolve = { string in
            
            let isSberQR = qrResolverFeatureFlag.isActive ? model.isSberQR : { _ in false }
            let resolver = QRResolver(isSberQR: isSberQR)
            
            return resolver.resolve(string: string)
        }
        
        let composer = QRScanResultMapperComposer(
            flag: utilitiesPaymentsFlag,
            model: model
        )
        let mapper = composer.compose()
        
        return {
            
            return .init(
                mapScanResult: mapper.mapScanResult(_:_:),
                makeQRModel: { .init(closeAction: $0, qrResolve: qrResolve) },
                scheduler: scheduler
            )
        }
    }
}
