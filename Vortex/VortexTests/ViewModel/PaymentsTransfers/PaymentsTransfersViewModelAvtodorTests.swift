//
//  PaymentsTransfersViewModelAvtodorTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 09.06.2023.
//

@testable import Vortex
import XCTest

final class PaymentsTransfersViewModelAvtodorTests: XCTestCase {
    
    func test_replacingAvtodors_shouldReturnSame_onNil() {
        
        let operators: [OperatorGroupData.OperatorData] = .transport
        let result = operators.replacingAvtodors(with: nil)
        
        XCTAssertNoDiff(result, operators)
    }
    
    func test_replacingAvtodors_shouldSubstituteAvtodorsWithProvided_onNonNil() {
        
        let operators: [OperatorGroupData.OperatorData] = .transport
        let result = operators.replacingAvtodors(with: .iVortex4285)
        
        XCTAssertNoDiff(result, [.iVortex4285] + .transportWithoutAvtodor)
    }
    
    // MARK: - Helpers Tests
    
    func test_bothAvtodors_shouldHaveSameINN() {
        
        let avtodors: [OperatorGroupData.OperatorData] = .avtodors
        let avtodorINN = "7710965662"
        
        XCTAssertEqual(avtodors.map(\.synonymList).count, 2)
        XCTAssertNoDiff(avtodors.map(\.synonymList)[0], [avtodorINN])
        XCTAssertNoDiff(avtodors.map(\.synonymList)[1], [avtodorINN])
    }
    
    func test_transportOperators_shouldHaveTransportParentCode() {
        
        let operators: [OperatorGroupData.OperatorData] = .transport
        let transportParentCode = "iVortex||1051062"
        
        XCTAssertTrue(operators.map(\.parentCode).allSatisfy({ $0 == transportParentCode }))
        XCTAssertEqual(operators.map(\.parentCode).count, 7)
    }
}

extension Array where Element == OperatorGroupData.OperatorData {
    
    static let transportWithoutAvtodor: Self = [
        .iVortexGibdd,
        .iVortexMosParking,
        .iVortexPodorozhnik,
        .iVortexStrelka,
        .iVortexTroika,
    ]
    static let avtodors: Self = [
        .iVortexAVDD,
        .iVortexAVDТ,
    ]
    static var transport: Self { .transportWithoutAvtodor + .avtodors }
}
