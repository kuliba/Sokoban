//
//  ContentPreviewForBuild.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 25.10.2023.
//

import Foundation
import PaymentSticker

extension BusinessLogic {
    
    static let preview: BusinessLogic = .init(
        dictionaryService: { fatalError() }(),
        transfer: { fatalError() }(),
        reduce: { fatalError() }()
    )
}

extension OperationStateViewModel {
    
    static let previewWithBusinessLogic: OperationStateViewModel = .init(
        businessLogic: .preview
    )
    
    convenience init(
        businessLogic: BusinessLogic
    ) {
        self.init(blackBoxGet: { request, completion in
            
            let (operation, event) = request
            businessLogic.operationResult(
                operation: operation,
                event: event,
                completion: completion
            )
        })
    }
}
