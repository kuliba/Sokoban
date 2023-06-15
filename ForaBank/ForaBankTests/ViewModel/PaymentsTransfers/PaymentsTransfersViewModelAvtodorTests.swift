//
//  PaymentsTransfersViewModelAvtodorTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.06.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsTransfersViewModelAvtodorTests: XCTestCase {
    
    func test_substitutingAvtodors_shouldReturnSame_onNil() {
        
        let operators: [OperatorGroupData.OperatorData] = .transport
        
        let result = operators.substitutingAvtodors(with: nil)
        
        XCTAssertNoDiff(result, operators)
    }
    
    func test_substitutingAvtodors_shouldSubstituteAvtodorsWithProvided_onNonNil() {
        
        let operators: [OperatorGroupData.OperatorData] = .transport
        
        let result = operators.substitutingAvtodors(with: .iFora4285)
        
        XCTAssertNoDiff(result, [.iFora4285] + .transportWithoutAvtodor)
    }
    
    // MARK: - Helpers Tests
    
    func test_bothAvtodors_shouldHaveSameINN() {
        
        let avtodors: [OperatorGroupData.OperatorData] = .avtodors
        let avtodorINN = "7710965662"
        
        XCTAssertTrue(avtodors.map(\.synonymList).allSatisfy({ $0 == [avtodorINN] }))
    }
    
    func test_transportOperators_shouldHaveTransportParentCode() {
        
        let operators: [OperatorGroupData.OperatorData] = .transport
        let transportParentCode = "iFora||1051062"
        
        XCTAssertTrue(operators.map(\.parentCode).allSatisfy({ $0 == transportParentCode }))
    }
}

extension Array where Element == OperatorGroupData.OperatorData {
    
    static let transportWithoutAvtodor: Self = [
        .iFora4811Gibdd,
        .iFora4990MosParking,
        .iForaPYDPodorozhnik,
        .iFora5300Strelka,
        .iForaMMRTroika,
        .iFora5173GibddFines,
    ]
    static let avtodors: Self = [
        .iForaAVDD,
        .iForaAVDТ,
    ]
    static var transport: Self { .transportWithoutAvtodor + .avtodors }
}
