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
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, dictionarySpy, transferSpy, makeSpy, imageLoaderSpy) = makeSUT()
        
        XCTAssertNoDiff(dictionarySpy.callCount, 0)
        XCTAssertNoDiff(transferSpy.callCount, 0)
        XCTAssertNoDiff(makeSpy.callCount, 0)
        XCTAssertNoDiff(imageLoaderSpy.callCount, 0)
    }  
    
    //MARK: Input Event Process
    
    func test_process_valueUpdate_shouldReturnUpdateOperation() throws {
        
        let (sut, _, _, _, _) = makeSUT()

        let inputParameter = Operation.Parameter.Input(
            value: "value",
            title: .code,
            warning: nil
        )
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub(
                parameters: [.input(inputParameter)]
            )),
            event: .input(.valueUpdate("value"))
        )
    }
    
    //MARK: Select Event Process
    
    func test_process_selectOption_transferTypeStickerCourier_shouldReturnUpdateOperation() throws {
    
        let (sut, _, _, _, _) = makeSUT()

        let selectParameter = Operation.Parameter.Select(
            id: .transferTypeSticker,
            value: "value",
            title: "title",
            placeholder: "placeholder",
            options: [.init(
                id: "id",
                name: "Доставка курьером",
                iconName: "iconName"
            )],
            staticOptions: [],
            state: .idle(.init(
                iconName: "",
                title: "title"
            )))
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub(
                parameters: [.select(.init(
                    id: .transferTypeSticker,
                    value: "id",
                    title: "title",
                    placeholder: "placeholder",
                    options: [.init(
                        id: "id",
                        name: "Доставка курьером",
                        iconName: "iconName"
                    )],
                    staticOptions: [],
                    state: .selected(.init(
                        title: "title",
                        placeholder: "Доставка курьером",
                        name: "Доставка курьером",
                        iconName: "iconName"
                    ))))]
            )),
            event: .select(.selectOption(
                .init(iconName: "iconName", name: "Доставка курьером"),
                selectParameter
            ))
        )
    }
    
    func test_process_selectOption_transferTypeStickerOffice_shouldReturnUpdateOperation() throws {
    
        let (sut, _, _, _, _) = makeSUT()

        let selectParameter = Operation.Parameter.Select(
            id: .transferTypeSticker,
            value: "value",
            title: "title",
            placeholder: "placeholder",
            options: [.init(
                id: "id",
                name: "Получить в офисе",
                iconName: "iconName"
            )],
            staticOptions: [],
            state: .idle(.init(
                iconName: "",
                title: "title"
            )))
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub(
                parameters: [.select(.init(
                    id: .transferTypeSticker,
                    value: "id",
                    title: "title",
                    placeholder: "placeholder",
                    options: [.init(
                        id: "id",
                        name: "Получить в офисе",
                        iconName: "iconName"
                    )],
                    staticOptions: [],
                    state: .selected(.init(
                        title: "title",
                        placeholder: "Получить в офисе",
                        name: "Получить в офисе",
                        iconName: "iconName"
                    ))))]
            )),
            event: .select(.selectOption(
                .init(iconName: "iconName", name: "Получить в офисе"),
                selectParameter
            ))
        )
    }
    
    func test_process_selectOption_officeSelector_shouldReturnUpdateOperation() throws {
    
        let (sut, _, _, _, _) = makeSUT()

        let selectParameter = Operation.Parameter.Select(
            id: .officeSelector,
            value: "value",
            title: "title",
            placeholder: "placeholder",
            options: [.init(id: "id", name: "name", iconName: "iconName")],
            staticOptions: [],
            state: .idle(.init(
                iconName: "",
                title: "title"
            )))
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub(
                parameters: [.select(.init(
                    id: .officeSelector,
                    value: "id",
                    title: "title",
                    placeholder: "placeholder",
                    options: [.init(id: "id", name: "name", iconName: "iconName")],
                    staticOptions: [],
                    state: .selected(.init(title: "title", placeholder: "name", name: "name", iconName: "iconName"))
                ))]
            )),
            event: .select(.selectOption(
                .init(iconName: "iconName", name: "name"),
                selectParameter
            ))
        )
    }
    
//    func test_process_selectOption_shouldReturnUpdateOperation() throws {
//    
//        let (sut, _, _, _, _) = makeSUT()
//
//        let selectParameter = Operation.Parameter.Select(
//            id: .citySelector,
//            value: "value",
//            title: "title",
//            placeholder: "placeholder",
//            options: [.init(id: "id", name: "name", iconName: "iconName")],
//            staticOptions: [],
//            state: .idle(.init(
//                iconName: "",
//                title: "title"
//            )))
//        
//        try expect(
//            sut,
//            operation: emptyOperation(),
//            expectedResult: .operation(emptyOperation(
//                parameters: [.select(.init(
//                    id: .citySelector,
//                    value: "value",
//                    title: "title",
//                    placeholder: "placeholder",
//                    options: [.init(id: "id", name: "name", iconName: "iconName")],
//                    staticOptions: [],
//                    state: .idle(.init(
//                        iconName: "",
//                        title: "title"
//                    ))))]
//            )),
//            event: .select(.selectOption(
//                .init(iconName: "iconName", name: "name"),
//                selectParameter
//            ))
//        )
//    }
    
    func test_process_search_shouldReturnUpdateOperation() throws {
    
        let (sut, _, _, _, _) = makeSUT()

        let selectParameter = Operation.Parameter.Select(
            id: .citySelector,
            value: "value",
            title: "title",
            placeholder: "placeholder",
            options: [],
            staticOptions: [],
            state: .idle(.init(
                iconName: "",
                title: "title"
            )))
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub(
                parameters: [.select(.init(
                    id: .citySelector,
                    value: "value",
                    title: "title",
                    placeholder: "placeholder",
                    options: [],
                    staticOptions: [],
                    state: .idle(.init(
                        iconName: "",
                        title: "title"
                    ))))]
            )),
            event: .select(.search("text", selectParameter))
        )
    }
    
    func test_process_chevronTapped_shouldReturnUpdateOperation() throws {
    
        let (sut, _, _, _, _) = makeSUT()

        let selectParameter = Operation.Parameter.Select(
            id: .citySelector,
            value: "value",
            title: "title",
            placeholder: "placeholder",
            options: [],
            staticOptions: [],
            state: .idle(.init(
                iconName: "",
                title: "title"
            )))
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub(
                parameters: [.select(.init(
                    id: .citySelector,
                    value: "value",
                    title: "title",
                    placeholder: "placeholder",
                    options: [],
                    staticOptions: [],
                    state: .list(.init(
                        iconName: "",
                        title: "title",
                        placeholder: "placeholder",
                        options: []
                    ))))]
            )),
            event: .select(.chevronTapped(selectParameter))
        )
    }
    
    func test_process_openBranch_shouldReturnUpdateOperation() throws {
    
        let (sut, _, _, _, _) = makeSUT()

        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub()),
            event: .select(.openBranch(.init(id: "")))
        )
    }
    
    //MARK: Dictionary Service Tests
    func test_init_shouldNotCallDictionaryProcess1() throws {
        
        let (sut, _, _, _, _) = makeSUT()
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub(
                state: .process
            )),
            event: .continueButtonTapped(.continue)
        )
    }
    
    func test_process_shouldCallDictionaryServiceWithPayload() throws {
        
        let payload: [GetJsonAbroadType] = [.stickerOrderForm]
        let (sut, dict, _, _, _) = makeSUT()

        _ = try process(
            sut,
            operation: operationStub(),
            event: .continueButtonTapped(.continue)
        )
        
        XCTAssertNoDiff(dict.requests, payload)
    }
    
    //MARK: Product Event
    
    func test_process_product_selectOption_withNilOption_shouldUpdateOperationState() throws {
        
        let (sut, _, _, _, _) = makeSUT()
        
        let product = Event.ParameterProduct(
            state: .list,
            selectedProduct: .init(
                id: 1,
                title: "title",
                nameProduct: "nameProduce",
                balance: 1,
                balanceFormatted: "1",
                description: "description",
                cardImage: .named(""),
                paymentSystem: .named(""),
                backgroundImage: nil,
                backgroundColor: "",
                clover: .named("")
            ),
            allProducts: []
        )
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(operationStub()),
            event: .product(.selectProduct(nil, product))
        )
    }
    
    func test_process_product_selectOption_shouldUpdateOperationState() throws {
        
        let (sut, _, _, _, _) = makeSUT()
        
        let product = Event.ParameterProduct(
            state: .list,
            selectedProduct: .init(
                id: 1,
                title: "title",
                nameProduct: "nameProduce",
                balance: 1,
                balanceFormatted: "1",
                description: "description",
                cardImage: .named(""),
                paymentSystem: .named(""),
                backgroundImage: nil,
                backgroundColor: "",
                clover: .named("")
            ),
            allProducts: []
        )
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(.init(parameters: [
                .productSelector(.init(
                    state: .select,
                    selectedProduct: .init(
                        id: 1,
                        title: "title",
                        nameProduct: "nameProduce",
                        balance: 1,
                        balanceFormatted: "1",
                        description: "description",
                        cardImage: .named(""),
                        paymentSystem: .named(""),
                        backgroundImage: nil,
                        backgroundColor: "",
                        clover: .named("")
                    ), allProducts: []
                ))
            ])),
            event: .product(.selectProduct(.init(
                id: 1,
                title: "title",
                nameProduct: "nameProduce",
                balance: 1,
                balanceFormatted: "1",
                description: "description",
                cardImage: .named(""),
                paymentSystem: .named(""),
                backgroundImage: nil,
                backgroundColor: "",
                clover: .named("")
            ), product))
        )
    }
    
    func test_process_product_shouldUpdateOperationState() throws {
        
        let (sut, _, _, _, _) = makeSUT()
        
        let product = Event.ParameterProduct(
            state: .list,
            selectedProduct: .init(
                id: 1,
                title: "title",
                nameProduct: "nameProduce",
                balance: 1,
                balanceFormatted: "1",
                description: "description",
                cardImage: .named(""),
                paymentSystem: .named(""),
                backgroundImage: nil,
                backgroundColor: "",
                clover: .named("")
            ),
            allProducts: []
        )
        
        try expect(
            sut,
            operation: operationStub(),
            expectedResult: .operation(.init(parameters: [
                .productSelector(.init(
                    state: .select,
                    selectedProduct: .init(
                        id: 1,
                        title: "title",
                        nameProduct: "nameProduce",
                        balance: 1,
                        balanceFormatted: "1",
                        description: "description",
                        cardImage: .named(""),
                        paymentSystem: .named(""),
                        backgroundImage: nil,
                        backgroundColor: "",
                        clover: .named("")
                    ), allProducts: []
                ))
            ])),
            event: .product(.chevronTapped(product, .select))
        )
    }
    
    typealias SUT = BusinessLogic
    typealias State = OperationStateViewModel.State
    
    func process(
        _ sut: SUT,
        operation: PaymentSticker.Operation,
        event: Event,
        action: @escaping () -> Void = {}
    ) throws -> BusinessLogic.OperationResult {
        
        var result: BusinessLogic.OperationResult?
        let exp = expectation(description: "wait for completion")
        
        sut.process(
            operation: operation,
            event: event) {
                
                result = $0
                exp.fulfill()
            }
        
        action()
        
        wait(for: [exp], timeout: 0.05)
        
        return try XCTUnwrap(result)
    }
    
    private func expect(
        _ sut: SUT,
        operation: PaymentSticker.Operation,
        expectedResult: OperationStateViewModel.State,
        event: Event,
        action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

        let result = try process(
            sut,
            operation: operation,
            event: event,
            action: action
        )
        
        XCTAssertNoDiff(try result.get(), expectedResult, file: file, line: line)
    }
    
    // MARK: Get Payment Sticker
    
    func test_getStickerPayment_shouldReturnDeliveryTypeOffice() {
        
        let (sut, _, _, _, _) = makeSUT()
        
        let result = sut.getStickerPayment(
            parameters: getOperation(transferTypeValue: "typeDeliveryOffice").parameters
        )
        
        let expect = PaymentSticker.StickerPayment(
            currencyAmount: "RUB",
            amount: 790,
            check: false,
            payer: .init(cardId: "1"),
            productToOrderInfo: .init(
                type: "STICKER",
                deliverToOffice: true,
                officeId: "1",
                cityId: nil
        ))
        
        XCTAssertNoDiff(result, expect)
    }
    
    func test_getStickerPayment_shouldReturnDeliveryTypeCourier() {
        
        let (sut, _, _, _, _) = makeSUT()
        
        let result = sut.getStickerPayment(
            parameters: getOperation(transferTypeValue: "typeDeliveryCourier").parameters
        )
        
        let expect = PaymentSticker.StickerPayment(
            currencyAmount: "RUB",
            amount: 1500,
            check: false,
            payer: .init(cardId: "1"),
            productToOrderInfo: .init(
                type: "STICKER",
                deliverToOffice: false,
                officeId: "1",
                cityId: 1
        ))
        
        XCTAssertNoDiff(result, expect)
    }
    
    // MARK: Helpers
    
    private func operationStub(
        state: PaymentSticker.Operation.State = .userInteraction,
        parameters: [PaymentSticker.Operation.Parameter] = []
    ) -> PaymentSticker.Operation {
        
        .init(state: state, parameters: parameters)
    }
    
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
    
    private func getCitySelectorParameter(
    ) -> PaymentSticker.Operation.Parameter {
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
    
    private func getOfficeSelectorParameter(
    ) -> PaymentSticker.Operation.Parameter {
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
                backgroundColor: "color",
                clover: .named("")
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
        
        let dictionarySpy = DictionarySpy()
        let transferSpy = TransferSpy()
        let makeSpy = MakeSpy()
        let imageLoaderSpy = ImageLoaderSpy()
        
        let sut = PaymentSticker.BusinessLogic(
            processDictionaryService: dictionarySpy.process(_:_:),
            processTransferService: transferSpy.process(_:_:),
            processMakeTransferService: makeSpy.process(_:_:),
            processImageLoaderService: imageLoaderSpy.process(_:_:),
            selectOffice: {_,_  in },
            products: { return [] },
            cityList: { _ in return [] }
        )
        
//        trackForMemoryLeaks(spyDictionary, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, dictionarySpy, transferSpy, makeSpy, imageLoaderSpy)
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
