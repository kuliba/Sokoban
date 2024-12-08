//
//  OperatorDataTestHelpersTests.swift
//  VortexTests
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
        
        XCTAssertEqual(purefs, ["iVortex||Addressing", "iVortex||Addressless", "iVortex||ChangeOutgoing", "iVortex||ReturnOutgoing", "iVortex||4630", "iVortex||5872", "iVortex||C31", "iVortex||DEMO3841", "iVortex||DEMO4177", "iVortex||KSK", "iVortex||MOO2", "iVortex||PIK", "iVortex||RIZ", "iVortex||TNS", "iVortex||UKIRR", "iVortex||ULENR", "iVortex||4285", "iVortex||4286", "iVortex||515", "iVortex||515A3", "iVortex||5536", "iVortex||5576", "iVortex||5814", "iVortex||6169", "iVortex||BE6", "iVortex||MM5", "iVortex||RR9", "iVortex||TEL", "iVortex||YSC", "iVortex||4811", "iVortex||4990", "iVortex||5173", "iVortex||5300", "iVortex||AVDD", "iVortex||AVDТ", "iVortex||MMR", "iVortex||PYD", "iVortex||PullMe2MeSTEP", "iVortex||PullSBPSTEP", "iVortex||SetBankDefSTEP", "iVortex||TransferC2CSTEP", "iVortex||TransferMe2MeSTEP", "iVortex||TransferArdshinClientP", "iVortex||TransferArmBBClientP", "iVortex||TransferEvocaClientP", "iVortex||TransferIDClientP", "iVortex||5090", "iVortex||5091", "iVortex||5092", "iVortex||AAA", "iVortex||MMM", "iVortex||MMMSTEP", "iVortex||5429", "iVortex||6273", "iVortex||6887", "iVortex||7069"])
    }
    
    typealias OperatorData = OperatorGroupData.OperatorData
    
    // MARK: - date(for:)
    
    func test_data_helper() throws {
        
        let data = OperatorData.data(for: "iVortex||4285")

        XCTAssertEqual(data?.name, "Билайн")
        XCTAssertEqual(data?.code, "iVortex||4285")
        XCTAssertEqual(data?.operatorID, "a3_NUMBER_1_2")
    }
    
    func test_data_iVortex4285() throws {
        
        let data = OperatorData.iVortex4285
        
        XCTAssertEqual(data.name, "Билайн")
        XCTAssertEqual(data.code, "iVortex||4285")
        XCTAssertEqual(data.operatorID, "a3_NUMBER_1_2")
    }
    
    func test_data_iVortex4286() throws {
        
        let data = OperatorData.iVortex4286
        
        XCTAssertEqual(data.name, "МТС")
        XCTAssertEqual(data.code, "iVortex||4286")
        XCTAssertEqual(data.operatorID, "a3_NUMBER_1_2")
    }
    
    func test_data_iVortex515A3() throws {
        
        let data = OperatorData.iVortex515A3
        
        XCTAssertEqual(data.name, "Yota")
        XCTAssertEqual(data.code, "iVortex||515A3")
        XCTAssertEqual(data.operatorID, nil)
    }
    
    // MARK: - Strings
    
    func test_operatorData_iVortex4285() throws {
        
        let operatorData = try operatorData(from: .operatorData_iVortex4285)
        
        XCTAssertEqual(operatorData, .iVortex4285)
    }
    
    func test_operatorData_iVortex4286() throws {
        
        let operatorData = try operatorData(from: .operatorData_iVortex4286)
        
        XCTAssertEqual(operatorData, .iVortex4286)
    }
    
    func test_operatorData_iVortex515A3() throws {
        
        let operatorData = try operatorData(from: .operatorData_iVortex515A3)
        
        XCTAssertEqual(operatorData, .iVortex515A3)
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
    
    static let iVortex4285:  Self = .data(for: "iVortex||4285")!
    static let iVortex4286:  Self = .data(for: "iVortex||4286")!
    static let iVortex515A3: Self = .data(for: "iVortex||515A3")!
    
    // transport
    static let iVortexGibdd:       Self = .data(for: Purefs.iVortexGibdd)!
    static let iVortexMosParking:  Self = .data(for: Purefs.iVortexMosParking)!
    static let iVortexPodorozhnik: Self = .data(for: Purefs.iVortexPodorozhnik)!
    static let iVortexStrelka:     Self = .data(for: Purefs.iVortexStrelka)!
    // backend has  changes not reflected in local files
    // TODO: change to `.data(for: Purefs.iVortexTroika)!` after local resources update
    static let iVortexTroika:      Self = .data(for: "\(Config.puref)||MMR")!
    
    // Avtodor
    static let iVortexAVDD: Self = .data(for: Purefs.avtodorContract)!
    static let iVortexAVDТ: Self = .data(for: Purefs.avtodorTransponder)!
    
    // helper
    static func data(for code: String) -> Self? {
        
        try? OperatorGroupData
            .fromBundle()
            .flatMap { $0.operators }
            .first { $0.code.normalizedOperatorCode() == code.normalizedOperatorCode() }
    }
}

private extension String {
    
    func normalizedOperatorCode() -> String {
        
        self.replacingOccurrences(of: "iVortex", with: Config.puref)
    }
}
