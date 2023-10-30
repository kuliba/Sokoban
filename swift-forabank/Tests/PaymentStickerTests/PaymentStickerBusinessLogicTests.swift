//
//  PaymentStickerBusinessLogicTests.swift
//  
//
//  Created by Дмитрий Савушкин on 26.10.2023.
//

import PaymentSticker
import XCTest

struct Operation: Equatable {

    let parameter: Parameter
    
    struct Parameter: Equatable {
        
        let selectedProduct: Product
        let allProducts: [Product]
        
        struct Product: Equatable {
            
            let id: ProductID
        }
    }
}

struct OperationSuccess {}
struct OperationFailure {}

enum OperationResult {
    
    case success(OperationSuccess)
    case failure(OperationFailure)
}

enum OperationState {
    
    case operation(Operation)
    case result(OperationResult)
}

struct ProductID: Equatable {
    
    let id: String
}

enum Event {
    
    case selectProduct(ProductID)
}

enum TransferEvent {
    
    case makePayment(BusinessLogic.Payload)
    case requestOtp
}

//TODO: rename PaymentStickerBusinessLogic
final class BusinessLogic {

    typealias TransferResult = Result<TransferResponse, Error>
    typealias TransferCompletion = (TransferResult) -> Void
    typealias Transfer = (TransferEvent, @escaping TransferCompletion) -> Void
    
    private let transfer: Transfer
    private let productIDs: [ProductID]
    
    init(
        transfer: @escaping Transfer,
        productIDs: [ProductID]
    ) {
        self.transfer = transfer
        self.productIDs = productIDs
    }
    
    typealias MakePaymentResult = Result<TransferResponse, TransferError>
    typealias MakePaymentCompletion = (MakePaymentResult) -> Void
    
    func handleTransferEvent(
        _ event: TransferEvent,
        completion: @escaping MakePaymentCompletion
    ) {
        switch event {
        case let .makePayment(payload):
            transfer(.makePayment(payload)) { [weak self] result in
                
                guard self != nil else { return }
                
                completion(result
                    .mapError { _ in .makePayment }
                )
            }
            
        case .requestOtp:
            transfer(.requestOtp) { [weak self] result in

                guard self != nil else { return }

                completion(result.mapError { _ in .otp })
            }
        }
    }
    
    typealias SelectResult = Result<Operation, Error>
    typealias SelectCompletion = (SelectResult) -> Void
    
    func selectProductID(
        operation: Operation,
        productID: ProductID,
        completion: @escaping SelectCompletion
    ) {
        guard productIDs.contains(productID) else {
            completion(.failure(MissingID()))
            return
        }
        
        let newOperation = Operation(parameter: .init(
            productId: productID,
            options: []
        ))
        completion(.success(newOperation))
    }
    
    struct MissingID: Error {}
    
    typealias Options = [Operation.Parameter.Option]
    typealias TappedResult = Result<Operation, ProductOptionsError>
    typealias ChevronTappedCompletion = (TappedResult) -> Void
    
    func chevronTapped(
        operation: Operation,
        options: Options,
        completion: @escaping ChevronTappedCompletion
    ) {
        
        guard operation.parameter.options.isEmpty else {
            completion(.failure(ProductOptionsError()))
            return
        }
       
        let newOperation = Operation(parameter: .init(
            productId: operation.parameter.productId,
            options: options
        ))
        
        completion(.success(newOperation))
    }
    
    struct Payload {}
    
    struct Response {}
    
    enum TransferResponse: Equatable {
        
        case otp
        case payment
    }
    
    enum TransferError: Error {
        
        case makePayment
        case otp
    }
    
    struct ProductOptionsError: Error {}
}

final class PaymentStickerBusinessLogicTests: XCTestCase {
    
    func test_init_shouldNotCallTransfer() {
        
        let (_, spy) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_transfer_makePayment_shouldDeliverError_onTransferFailure() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: makePaymentEvent(), toDeliver: [.failure(.makePayment)]) {
            
            spy.complete(with: anyError())
        }
    }
    
    func test_transfer_makePayment_shouldDeliverResponse_onTransferSuccess() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: makePaymentEvent(), toDeliver: [.success(.payment)]) {
            
            spy.complete(with: .payment)
        }
    }
    
    func test_transfer_makePayment_shouldNotDeliverResponse_onInstanceDeallocation() {
        
        var sut: SUT?
        let spy: TransferSpy
        (sut, spy) = makeSUT()
        var receivedResult = [SUT.MakePaymentResult]()
        
        sut?.handleTransferEvent(makePaymentEvent()) { receivedResult.append($0) }
        sut = nil
        spy.complete(with: anyError())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssert(receivedResult.isEmpty)
    }
    
    func test_transfer_requestOtp_shouldDeliverError_onTransferFailure() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: makeRequestOtpEvent(), toDeliver: [.failure(.otp)]) {
            
            spy.complete(with: anyError())
        }
    }
    
    func test_transfer_requestOtp_shouldDeliverResult_onTransferSuccess() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: makeRequestOtpEvent(), toDeliver: [.success(.otp)]) {
            
            spy.complete(with: .otp)
        }
    }
    
    func test_transfer_requestOtp_shouldNotDeliverResponse_onInstanceDeallocation() {
        
        var sut: SUT?
        let spy: TransferSpy
        (sut, spy) = makeSUT()
        var receivedResult = [SUT.MakePaymentResult]()
        
        sut?.handleTransferEvent(makeRequestOtpEvent()) { receivedResult.append($0) }
        sut = nil
        spy.complete(with: anyError())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssert(receivedResult.isEmpty)
    }
    
    func test_selectProductID_shouldDeliverError_onMissingProductID() {
        
        let missingID = ProductID(id: "missing")
        let operation = makeOperation()
        let (sut, _) = makeSUT()
        
        expect(sut, operation: operation, with: missingID, toDeliver: [.failure(SUT.MissingID())]) {}
    }
    
    func test_selectProductID_shouldChangeParameterId_onExistingProductID() {
        
        let existingID = ProductID(id: "existing")
        let operation = makeOperation()
        let (sut, _) = makeSUT(productIDs: [existingID])
        let newOperation = Operation(parameter: .init(
            productId: existingID,
            options: []
        ))
        
        expect(sut, operation: operation, with: existingID, toDeliver: [.success(newOperation)]) {}
    }
    
    func test_chevronTapped_shouldReturnOption() {
        
        let operation = makeOperation()
        let options = makeOptions()
        let (sut, _) = makeSUT()
        let newOperation = Operation(parameter: .init(
            productId: .init(id: "123"),
            options: options
        ))
        
        expect(sut, operation: operation, with: options, toDeliver: [.success(newOperation)]){}
    }
    
    func test_chevronTapped_shouldReturnError() {

        let operation = makeOperation(parameter: .init(
            productId: .init(id: "123"),
            options: [.init(id: "1")]
        ))
        let options = makeOptions()
        let (sut, _) = makeSUT()

        expect(sut, operation: operation, with: options, toDeliver: [.failure(.init())]){}
    }
    
    // MARK: - Helpers
    
    typealias SUT = BusinessLogic
    typealias TransferResult = SUT.TransferResult
    typealias Payload = SUT.Payload
    typealias Response = SUT.TransferResponse
    
    private func makeSUT(
        productIDs: [ProductID] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        transferSpy: TransferSpy
    ) {
        let transferSpy = TransferSpy()
        let sut = SUT(
            transfer: transferSpy.transfer,
            productIDs: productIDs
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(transferSpy, file: file, line: line)
        
        return (sut, transferSpy)
    }
    
    private final class TransferSpy {
        
        typealias Completion = SUT.TransferCompletion
        typealias Message = (event: TransferEvent, completion: Completion)
        
        private(set) var messages = [Message]()
        
        func transfer(
            _ event: TransferEvent,
            _ completion: @escaping Completion
        ) {
            messages.append((event, completion))
        }
        
        func complete(
            with error: Error,
            at index: Int = 0
        ) {
            messages[index].completion(.failure(error))
        }
                
        func complete(
            with response: Response,
            at index: Int = 0
        ) {
            messages[index].completion(.success(response))
        }
    }
    
    private func makeOperation(
        parameter: Operation.Parameter = .init(productId: .init(id: "123"), options: [])
    ) -> Operation {
        
        .init(parameter: parameter)
    }
    
    private func makeOptions(
        options: [Operation.Parameter.Option] = [.init(id: "1")]
    ) -> [Operation.Parameter.Option] {
        
        options
    }
    
    private func makeRequestOtpEvent() -> TransferEvent {
    
        .requestOtp
    }
    
    private func makePaymentEvent() -> TransferEvent {
    
        .makePayment(anyPayload())
    }
    
    private func anyPayload() -> BusinessLogic.Payload {
        
        .init()
    }
    
    private func expect(
        _ sut: SUT,
        operation: Operation,
        with options: [Operation.Parameter.Option],
        toDeliver expectedResults: [SUT.TappedResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.TappedResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.chevronTapped(
            operation: operation,
            options: options
        ) {
                
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        assert(receivedResults, equalsTo: expectedResults, file: file, line: line)
    }
    
    private func expect(
        _ sut: SUT,
        operation: Operation,
        with productID: ProductID,
        toDeliver expectedResults: [SUT.SelectResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.SelectResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.selectProductID(
            operation: operation,
            productID: productID
        ) {
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        assert(receivedResults, equalsTo: expectedResults, file: file, line: line)
    }
    
    private func expect(
        _ sut: SUT,
        with event: TransferEvent,
        toDeliver expectedResults: [SUT.MakePaymentResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.MakePaymentResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.handleTransferEvent(event) { result in
            
            receivedResults.append(result)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        assert(receivedResults, equalsTo: expectedResults, file: file, line: line)
    }
    
    private func assert<T: Equatable, E: Error>(
        _ receivedResults: [Result<T, E>],
        equalsTo expectedResults: [Result<T, E>],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(receivedResults.count, expectedResults.count, "Expected \(expectedResults.count) values, but got \(receivedResults.count).")
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, element in
                
                let (received, expected) = element
                
                switch (received, expected) {
                case let (.success(received), .success(expected)):
                    XCTAssertEqual(received, expected, file: file, line: line)
                    
                case let (
                    .failure(received as NSError),
                    .failure(expected as NSError)
                ):
                    XCTAssertEqual(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("Expected \(expectedResults), got \(receivedResults).", file: file, line: line)
                }
            }
    }
}
