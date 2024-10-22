//
//  ModelRootFactory+shared.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2024.
//

extension ModelRootFactory {
    
    static let shared: ModelRootFactory = .init(
        logger: LoggerAgent.shared,
        model: Model.shared
    )
}
