//
//  RootViewModelFactory+makeMakeQRScannerModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

extension RootViewModelFactory {
    
    func makeMakeQRScannerModel(
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    ) -> () -> QRModel {
        
        let composer = QRScannerComposer(
            model: model,
            qrResolverFeatureFlag: qrResolverFeatureFlag,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            scheduler: schedulers.main
        )
        
        return composer.compose
    }
}
