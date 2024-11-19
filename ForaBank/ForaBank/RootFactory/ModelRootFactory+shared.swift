//
//  ModelRootFactory+shared.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2024.
//

extension ModelRootFactory {
    
    static var shared: ModelRootFactory {
        
        let model: Model = .shared
        
        let qrResolve: QRViewModel.QRResolve = { string in
            
            let resolver = QRResolver(isSberQR: model.isSberQR)
            
            return resolver.resolve(string: string)
        }
        
        return .init(
            httpClientFactory: ModelHTTPClientFactory(
                logger: LoggerAgent.shared,
                model: model
            ),
            logger: LoggerAgent.shared,
            model: model,
            makeQRScanner: { QRViewModel(closeAction: $0, qrResolve: qrResolve) }
        )
    }
}
