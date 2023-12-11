//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 26.11.2023.
//

import Foundation
import PaymentSticker
import XCTest

final class PaymentStickerBusinessTests: XCTestCase {
    
    func test_init_shouldNotCallTransfer() {
        
        
    }
}

extension PaymentStickerBusinessTests {
    
    func makeSUT() -> OperationStateViewModel {
        
        let businessLogic = PaymentSticker.BusinessLogic(
            processDictionaryService: {_,_  in},
            processTransferService: {_,_  in},
            processMakeTransferService: {_,_  in},
            processImageLoaderService: {_,_  in},
            selectOffice: {_,_  in},
            products: [],
            cityList: []
        )
        let sut = OperationStateViewModel(blackBoxGet: businessLogic.operationResult)
        
        return sut
    }
}

private extension BusinessLogic {
    
    func operationResult(
        request: (
            operation: PaymentSticker.Operation,
            event: Event
        ),
        completion: @escaping (OperationResult) -> Void
    ) {
        
        operationResult(
            operation: request.operation,
            event: request.event,
            completion: completion
        )
    }
}
