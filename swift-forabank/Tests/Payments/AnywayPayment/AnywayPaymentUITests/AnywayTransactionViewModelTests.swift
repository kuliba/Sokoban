//
//  AnywayTransactionViewModelTests.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain

struct CachedModelsTransaction<Model, DocumentStatus, Response> {
    
    var models: [ID: Model]
    var transaction: Transaction
    
    typealias ID = AnywayElement.ID
    typealias Transaction = AnywayTransactionState<DocumentStatus, Response>
}

final class AnywayTransactionViewModel<Model, DocumentStatus, Response>: ObservableObject {
    
    @Published private(set) var state: State
    
    init(transaction: State.Transaction) {
        
        self.state = .init(
            models: [:],
            transaction: transaction
        )
    }
}

extension AnywayTransactionViewModel {
    
    typealias State = CachedModelsTransaction<Model, DocumentStatus, Response>
}

typealias AnywayTransactionState<DocumentStatus, Response> = Transaction<AnywayPaymentContext, Status<DocumentStatus, Response>>
typealias AnywayTransactionEvent<DocumentStatus, Response> = TransactionEvent<Report<DocumentStatus, Response>, AnywayPaymentEvent, AnywayPaymentUpdate>
typealias AnywayTransactionEffect = TransactionEffect<AnywayPaymentDigest, AnywayPaymentEffect>

typealias Status<DocumentStatus, Response> = TransactionStatus<Report<DocumentStatus, Response>>
typealias Report<DocumentStatus, Response> = TransactionReport<DocumentStatus, OperationInfo<OperationDetailID, OperationDetails<Response>>>

typealias OperationDetailID = Int

struct OperationDetails<Response> {
    
    let id: OperationDetailID
    let response: Response
}

extension OperationDetails: Equatable where Response: Equatable {}

import XCTest

final class AnywayTransactionViewModelTests: XCTestCase {
    
    func test_init_shouldSetTransactionValue() {
        
        let transaction = makeTransaction()
        let (sut, spy) = makeSUT(initial: transaction)
        
        XCTAssertNoDiff(spy.values.map(\.transaction), [transaction])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayTransactionViewModel<Model, DocumentStatus, Response>
    private typealias DocumentStatus = Int
    private typealias Response = String
    
    private typealias Spy = ValueSpy<SUT.State>
    
    private func makeSUT(
        initial: SUT.State.Transaction? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: Spy
    ) {
        let sut = SUT(transaction: initial ?? makeTransaction())
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private final class Model {
        
        var value: AnywayElement
        
        init(value: AnywayElement) {
            
            self.value = value
        }
    }
}
