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
    
    func test_init() {
        
        let (sut, spy) = makeSUT()
        spy.events
        
    }
}

private extension PaymentStickerBusinessTests {
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (BusinessLogic, Spy) {
        
        let sut = PaymentSticker.BusinessLogic(
            processDictionaryService: {_,_  in }, //TODO: setup SPY
            processTransferService: {_,_  in },
            processMakeTransferService: {_,_  in },
            processImageLoaderService: {_,_  in },
            selectOffice: {_,_  in },
            products: [],
            cityList: []
        )

    private final class ImageLoaderSpy {
        
        private(set) var messages = [(request: [String], completion: BusinessLogic.ImageLoaderCompletion)]()

        var callCount: Int { messages.count }
        var requests: [[String]] { messages.map(\.request) }
        
        func process(
            _ request: [String],
            _ completion: @escaping BusinessLogic.ImageLoaderCompletion
        ) {
         
            messages.append((request, completion))
        }
        
        func complete(
            with result: Result<[ImageData], GetImageListError>,
            at index: Int = 0
        ) {
            
            messages[index].completion(result)
        }
    }
    
    private final class MakeSpy {
        
        private(set) var messages = [(request: String, completion: BusinessLogic.MakeTransferCompletion)]()

        var callCount: Int { messages.count }
        var requests: [String] { messages.map(\.request) }
        
        func process(
            _ request: String,
            _ completion: @escaping BusinessLogic.MakeTransferCompletion
        ) {
         
            messages.append((request, completion))
        }
        
        func complete(
            with result: Result<MakeTransferResponse, MakeTransferError>,
            at index: Int = 0
        ) {
            
            messages[index].completion(result)
        }
    }
    
    private final class TransferSpy {
        
        private(set) var messages = [(request: StickerPayment, completion: BusinessLogic.TransferCompletion)]()

        var callCount: Int { messages.count }
        var requests: [StickerPayment] { messages.map(\.request) }
        
        func process(
            _ request: StickerPayment,
            _ completion: @escaping BusinessLogic.TransferCompletion
        ) {
         
            messages.append((request, completion))
        }
        
        func complete(
            with result: Result<CommissionProductTransfer, CommissionProductTransferError>,
            at index: Int = 0
        ) {
            
            messages[index].completion(result)
        }
    }
    
    private final class DictionarySpy {
        
        private(set) var messages = [(request: GetJsonAbroadType, completion: BusinessLogic.DictionaryCompletion)]()

        var callCount: Int { messages.count }
        var requests: [GetJsonAbroadType] { messages.map(\.request) }
        
        func process(
            _ request: GetJsonAbroadType,
            _ completion: @escaping BusinessLogic.DictionaryCompletion
        ) {
         
            messages.append((request, completion))
        }
        
        func complete(
            with result: Result<StickerDictionary, StickerDictionaryError>,
            at index: Int = 0
        ) {
            
            messages[index].completion(result)
        }
    }
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
