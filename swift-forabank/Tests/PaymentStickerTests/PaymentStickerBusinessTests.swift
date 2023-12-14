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
    
        let spy = Spy()
        
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, spy)
    }
    
    class Spy {
        
        private (set) var events = [Event]()
        
        func event(event: Event) {
            
            events.append(event)
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
