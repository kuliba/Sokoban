//
//  OperatorDataTestHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import ForaBank
import XCTest

final class OperatorDataTestHelpersTests: XCTestCase {
    
    // MARK: - fromBundle()
    
    func test_operatorGroupData() throws {
        
        let operatorGroupData = try operatorGroupData(from: .operatorGroupData)
        let bundled = try OperatorGroupData.fromBundle()
        
        XCTAssertEqual(operatorGroupData, bundled)
    }
    
    func test_dataFromBundle() throws {
        
        let operatorGroupData = try XCTUnwrap(OperatorGroupData.fromBundle())
        let purefs = operatorGroupData.flatMap { $0.operators.map(\.code) }
        
        XCTAssertEqual(purefs, ["iFora||Addressing", "iFora||Addressless", "iFora||ChangeOutgoing", "iFora||ReturnOutgoing", "iFora||4630", "iFora||5872", "iFora||C31", "iFora||DEMO3841", "iFora||DEMO4177", "iFora||KSK", "iFora||MOO2", "iFora||PIK", "iFora||RIZ", "iFora||TNS", "iFora||UKIRR", "iFora||ULENR", "iFora||4285", "iFora||4286", "iFora||515", "iFora||515A3", "iFora||5536", "iFora||5576", "iFora||5814", "iFora||6169", "iFora||BE6", "iFora||MM5", "iFora||RR9", "iFora||TEL", "iFora||YSC", "iFora||4811", "iFora||4990", "iFora||5173", "iFora||5300", "iFora||AVDD", "iFora||AVDТ", "iFora||MMR", "iFora||PYD", "iFora||PullMe2MeSTEP", "iFora||PullSBPSTEP", "iFora||SetBankDefSTEP", "iFora||TransferC2CSTEP", "iFora||TransferMe2MeSTEP", "iFora||TransferArdshinClientP", "iFora||TransferArmBBClientP", "iFora||TransferEvocaClientP", "iFora||TransferIDClientP", "iFora||5090", "iFora||5091", "iFora||5092", "iFora||AAA", "iFora||MMM", "iFora||MMMSTEP", "iFora||5429", "iFora||6273", "iFora||6887", "iFora||7069"])
    }
    
    typealias OperatorData = OperatorGroupData.OperatorData
    
    // MARK: - date(for:)
    
    func test_data_helper() throws {
        
        let data = OperatorData.data(for: "iFora||4285")

        XCTAssertEqual(data?.name, "Билайн")
        XCTAssertEqual(data?.code, "iFora||4285")
        XCTAssertEqual(data?.operatorID, "a3_NUMBER_1_2")
    }
    
    func test_data_iFora4285() throws {
        
        let data = OperatorData.iFora4285
        
        XCTAssertEqual(data.name, "Билайн")
        XCTAssertEqual(data.code, "iFora||4285")
        XCTAssertEqual(data.operatorID, "a3_NUMBER_1_2")
    }
    
    func test_data_iFora4286() throws {
        
        let data = OperatorData.iFora4286
        
        XCTAssertEqual(data.name, "МТС")
        XCTAssertEqual(data.code, "iFora||4286")
        XCTAssertEqual(data.operatorID, "a3_NUMBER_1_2")
    }
    
    func test_data_iFora515A3() throws {
        
        let data = OperatorData.iFora515A3
        
        XCTAssertEqual(data.name, "Yota")
        XCTAssertEqual(data.code, "iFora||515A3")
        XCTAssertEqual(data.operatorID, nil)
    }
    
    // MARK: - Strings
    
    func test_operatorData_iFora4285() throws {
        
        let operatorData = try operatorData(from: .operatorData_iFora4285)
        
        XCTAssertEqual(operatorData, .iFora4285)
    }
    
    func test_operatorData_iFora4286() throws {
        
        let operatorData = try operatorData(from: .operatorData_iFora4286)
        
        XCTAssertEqual(operatorData, .iFora4286)
    }
    
    func test_operatorData_iFora515A3() throws {
        
        let operatorData = try operatorData(from: .operatorData_iFora515A3)
        
        XCTAssertEqual(operatorData, .iFora515A3)
    }
    
    // MARK: - Helpers
    
    private func operatorGroupData(from data: Data) throws -> [OperatorGroupData] {
        
        try JSONDecoder().decode([OperatorGroupData].self, from: data)
    }
    
    private func operatorData(from json: String) throws -> OperatorData {
        
        let data = try XCTUnwrap(json.data(using: .utf8))
        return try JSONDecoder().decode(OperatorData.self, from: data)
    }
}

extension OperatorGroupData.OperatorData {
    
    static let iFora4285: Self = .data(for: "iFora||4285")!
    static let iFora4286: Self = .data(for: "iFora||4286")!
    static let iFora515A3: Self = .data(for: "iFora||515A3")!
    
    static func data(for code: String) -> Self? {
        
        try? OperatorGroupData
            .fromBundle()
            .flatMap { $0.operators }
            .first { $0.code == code }
    }
}
