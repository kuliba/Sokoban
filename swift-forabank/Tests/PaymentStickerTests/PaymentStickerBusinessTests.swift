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
        
        let sut = makeSUT()
        
        let parameterSelect = PaymentSticker.Operation.Parameter.Select(
            id: .transferTypeSticker,
            value: nil,
            title: "Title",
            placeholder: "Placeholder",
            options: [],
            state: .idle(.init(
                iconName: "",
                title: "Title"
            ))
        )
        
        sut.operationResult(
            operation: .init(parameters: []),
            event: .select(.chevronTapped(parameterSelect)),
            completion: { _ in }
        )
        
//        XCTAssertNoDifference(operation, <#T##() -> T#>)
    }
}

extension PaymentStickerBusinessTests {
    
    func makeSUT() -> PaymentSticker.BusinessLogic {
        
        return .init(
            processDictionaryService: {_,_  in},
            processTransferService: {_,_  in},
            processMakeTransferService: {_,_  in},
            processImageLoaderService: {_,_  in},
            selectOffice: {_,_  in},
            products: [],
            cityList: []
        )
    }
}
