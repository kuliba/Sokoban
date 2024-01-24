//
//  RootViewModelFactory+makeMakeQRScannerModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Foundation

extension RootViewModelFactory {
    
    static func makeMakeQRScannerModel(
        model: Model,
        qrResolverFeatureFlag: QRResolverFeatureFlag
    ) -> MakeQRScannerModel {
        
        let qrResolve: QRViewModel.QRResolve = { string in
            
            let isSberQR = qrResolverFeatureFlag.isActive ? model.isSberQR : { _ in false }
            let resolver = QRResolver(isSberQR: isSberQR)
            
            return resolver.resolve(string: string)
        }
        
        return {
            
            .init(closeAction: $0, qrResolve: qrResolve)
        }
    }
}
