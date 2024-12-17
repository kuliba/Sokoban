//
//  TransportPaymentsViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 16.06.2023.
//

@testable import ForaBank
import PickerWithPreviewComponent
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
    
    // MARK: - destinationForTrack
    
    func test_destinationForTrack_shouldReturnPaymentsForEmptyString() throws {
        
        let sut = makeSUT(operators: [])
        
        let destination = try sut.destination(for: .puref(""))
        
        switch destination {
        case .payment:
            break
            
        default:
            XCTFail("Expected \"payments\", got \(destination) instead.")
        }
    }
    
    // TODO: this test proves that String API is weak, consider replacing with strong type
    func test_destinationForTrack_shouldReturnPaymentsForNonEmptyString() throws {
        
        let sut = makeSUT(operators: [])
        
        let destination = try sut.destination(for: .puref("any"))
        
        switch destination {
        case .payment:
            break
            
        default:
            XCTFail("Expected \"payments\", got \(destination) insted.")
        }
    }
    
    func test_destinationForTrackAvtodorShouldReturnPayment() throws {
        
        let sut = makeSUT(operators: [])
        
        let puref = Purefs.avtodorGroup
        let destination = try sut.destination(for: .puref(puref))
        
        switch destination {
        case .payment:
            break
            
        default:
            XCTFail("Expected \"payment\", got \(destination) insted.")
        }
    }
    
    func test_destinationForTrackGibddShouldReturnPayment() throws {
        
        let sut = makeSUT(operators: [])
        
        let puref = Purefs.iForaGibdd
        let destination = try sut.destination(for: .puref(puref))
        
        switch destination {
        case .payment:
            break
            
        default:
            XCTFail("Expected \"payment\", got \(destination) insted.")
        }
    }
    
    func test_destinationForTrackMosParkingShouldReturnMosParking() throws {
        
        let sut = makeSUT(operators: [])
        
        let puref = Purefs.iForaMosParking
        let destination = try sut.destination(for: .puref(puref))
        
        switch destination {
        case .mosParking:
            break
            
        default:
            XCTFail("Expected \"mosParkingPicker\", got \(destination) insted.")
        }
    }
    
    // MARK: - selectPuref
    
    func test_selectPurefAvtodorShouldShouldSetDestinationToPayment() {
        
        let sut = makeSUT(operators: [])
        
        let puref = Purefs.avtodorGroup
        sut.select(track: .puref(puref))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        switch sut.destination {
        case .payment:
            break
            
        default:
            XCTFail("Expected \"payment\", got \(String(describing: sut.destination)) insted.")
        }
    }
    
    func test_selectPurefMosParkingShouldShouldSetDestinationToMosParking() {
        
        let sut = makeSUT(operators: [])
        
        let puref = Purefs.iForaMosParking
        sut.select(track: .puref(puref))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        switch sut.destination {
        case .mosParking:
            break
            
        default:
            XCTFail("Expected \"mosParkingPicker\", got \(String(describing: sut.destination)) insted.")
        }
    }
    
    func test_selectPurefGibddShouldShouldSetDestinationPayment()  {
        
        let sut = makeSUT(operators: [])
        
        let puref = Purefs.iForaGibdd
        sut.select(track: .puref(puref))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        switch sut.destination {
        case .payment:
            break
            
        default:
            XCTFail("Expected \"payment\", got \(String(describing: sut.destination)) insted.")
        }
    }
    
    // MARK: - viewOperators
    
    func test_viewOperators_shouldReturnEmptyOnEmptyOperators() {
        
        let sut = makeSUT(operators: [])
        
        XCTAssertNoDiff(sut.operators.count, 0)
        XCTAssertNoDiff(sut.viewOperators.count, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        operators: [OperatorGroupData.OperatorData],
        file: StaticString = #file,
        line: UInt = #line
    ) -> TransportPaymentsViewModel {
        
        let sut = TransportPaymentsViewModel(
            operators: operators,
            latestPayments: .sample,
            makePaymentsViewModel: makePaymentsViewModel
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makePaymentsViewModel(
        source: Payments.Operation.Source
    ) -> PaymentsViewModel {
        
        .init(
            source: source,
            model: .mockWithEmptyExcept(),
            closeAction: {}
        )
    }
}
