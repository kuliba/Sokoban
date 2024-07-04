//
//  TemplatesFlowManager+preview.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.07.2024.
//

extension TemplatesFlowManager {
    
    static let preview: Self = .init(
        reduce: { state, _ in (state, nil) },
        handleEffect: { _,_ in }
    )
}
