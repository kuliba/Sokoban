//
//  TransportPaymentsViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 16.06.2023.
//

@testable import ForaBank
import XCTest

final class TransportPaymentsViewModelTests: XCTestCase {
    
    // MARK: - operatorINN
    
    func test_operatorINN_shouldReturnEmptyForNil() {
        
        let sut = TransportPaymentsViewModel.ItemViewModel.operatorINN(for:)
        
        XCTAssertEqual(sut(nil), "")
    }
    
    func test_operatorINN_shouldReturnEmptyForEmpty() {
        
        let sut = TransportPaymentsViewModel.ItemViewModel.operatorINN(for:)
        
        XCTAssertEqual(sut(""), "")
    }
    
    func test_operatorINN_shouldReturnEmptyForNonDigits() {
        
        let sut = TransportPaymentsViewModel.ItemViewModel.operatorINN(for:)
        
        XCTAssertEqual(sut("Abcd"), "")
    }
    
    func test_operatorINN_shouldReturnEmptyForNonMix() {
        
        let sut = TransportPaymentsViewModel.ItemViewModel.operatorINN(for:)
        
        XCTAssertEqual(sut("A123bcd"), "")
    }
    
    func test_operatorINN_shouldReturnFormattedForDigits() {
        
        let sut = TransportPaymentsViewModel.ItemViewModel.operatorINN(for:)
        
        XCTAssertEqual(sut("1234567"), "ИНН 1234567")
    }
    
    // MARK: - linkForCode
    
    func test_linkForCode_shouldReturnPaymentsForEmptyString() {
        
        let sut = makeSUT(operators: [])
        
        let link = sut.link(for: "")
        
        switch link {
        case .payments:
            break
            
        default:
            XCTFail("Expected \"payments\", got \(link) insted.")
        }
    }
    
    // TODO: this test proves that String API is weak, consider replacing with strong type
    func test_linkForCode_shouldReturnPaymentsForNonEmptyString() {
        
        let sut = makeSUT(operators: [])
        
        let link = sut.link(for: "any")
        
        switch link {
        case .payments:
            break
            
        default:
            XCTFail("Expected \"payments\", got \(link) insted.")
        }
    }
    
    #warning("fix this test")
    // TODO: fix this test
//    func test_linkForCode() {
//        
//        let sut = makeSUT(operators: [])
//        
//        let puref = Purefs.avtodorGroup
//        let link = sut.link(for: puref)
//        
//        switch link {
//        case .avtodor:
//            break
//            
//        default:
//            XCTFail("Expected \"avtodor\", got \(link) insted.")
//        }
//    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        operators: [OperatorGroupData.OperatorData],
        file: StaticString = #file,
        line: UInt = #line
    ) -> TransportPaymentsViewModel {
        
        let sut = TransportPaymentsViewModel(
            operators: operators,
            latestPayments: .sample,
            navigationBar: .sample,
            makePaymentsViewModel: makePaymentsViewModel
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makePaymentsViewModel(
        source: Payments.Operation.Source
    ) -> PaymentsViewModel {
        
        .init(source: source, model: .mockWithEmptyExcept(), closeAction: {})
    }
}
