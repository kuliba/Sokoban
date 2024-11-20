//
//  ModelRootComposer+shared.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2024.
//

extension ModelRootComposer {
    
    static var shared: ModelRootComposer {
        
        let model: Model = .shared
        let resolver = QRResolver(isSberQR: model.isSberQR)
        
        return .init(
            httpClientFactory: ModelHTTPClientFactory(
                logger: LoggerAgent.shared,
                model: model
            ),
            logger: LoggerAgent.shared,
            model: model,
            resolveQR: resolver.resolve
        )
    }
}
