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
        
    
    // MARK: Helpers
    
    private func getOperation(
        transferTypeValue: String
    ) -> PaymentSticker.Operation {
        
        return .init(parameters: [
            getProductParameterStub(),
            getTransferTypeParameter(value: transferTypeValue),
            getCitySelectorParameter(),
            getOfficeSelectorParameter()
        ])
    }
    
    private func getTransferTypeParameter(
        value: String
    ) -> PaymentSticker.Operation.Parameter {
        return .select(.ParameterSelect(
            id: .transferTypeSticker,
            value: value,
            title: "title",
            placeholder: "placeholder",
            options: [],
            staticOptions: [],
            state: .idle(.init(
                iconName: "",
                title: "title"
            ))))
    }
    
    private func getCitySelectorParameter() -> PaymentSticker.Operation.Parameter{
        return .select(.ParameterSelect(
            id: .citySelector,
            value: "1",
            title: "title",
            placeholder: "placeholder",
            options: [],
            staticOptions: [],
            state: .idle(.init(
                iconName: "iconName",
                title: "title"
            ))))
    }
    
    private func getOfficeSelectorParameter() -> PaymentSticker.Operation.Parameter{
        return .select(.ParameterSelect(
            id: .officeSelector,
            value: "1",
            title: "title",
            placeholder: "placeholder",
            options: [],
            staticOptions: [],
            state: .idle(.init(
                iconName: "",
                title: "title"
            ))))
    }
    
    func getProductParameterStub() -> PaymentSticker.Operation.Parameter {
        
        .productSelector(.init(
            state: .select,
            selectedProduct: .init(
                id: 1,
                title: "",
                nameProduct: "nameProduct",
                balance: 10,
                balanceFormatted: "10",
                description: "description",
                cardImage: .named(""),
                paymentSystem: .named(""),
                backgroundImage: .named(""),
                backgroundColor: "color"
            ), 
            allProducts: []
        ))
    }
}

private extension PaymentStickerBusinessTests {
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (BusinessLogic, DictionarySpy, TransferSpy, MakeSpy, ImageLoaderSpy) {
        
        let dictinarySpy = DictionarySpy()
        let transferSpy = TransferSpy()
        let makeSpy = MakeSpy()
        let imageLoaderSpy = ImageLoaderSpy()
        
        let sut = PaymentSticker.BusinessLogic(
            processDictionaryService: dictinarySpy.process(_:_:),
            processTransferService: transferSpy.process(_:_:),
            processMakeTransferService: makeSpy.process(_:_:),
            processImageLoaderService: imageLoaderSpy.process(_:_:),
            selectOffice: {_,_  in },
            products: [],
            cityList: []
        )
        
//        trackForMemoryLeaks(spyDictionary, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, dictinarySpy, transferSpy, makeSpy, imageLoaderSpy)
    }

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
