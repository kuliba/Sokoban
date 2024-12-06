//
//  Model+getMosParkingListDataTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.06.2023.
//

@testable import ForaBank
import ServerAgent
import XCTest

final class Model_getMosParkingListDataTests: XCTestCase {
    
    func test_getMosParkingListData_shouldFailOnNotAuthorised() async throws {
        
        let sut = makeSUT(sessionAgent: SessionAgentEmptyMock())
        
        try await assertThrowsAsNSError(
            _ = try await sut.getMosParkingListData(),
            error: Payments.Error.notAuthorized
        )
    }
    
    func test_getMosParkingListData_shouldFailOnEmpty() async throws {
        
        let sut = makeSUT()
        
        try await assertThrowsAsNSError(
            _ = try await sut.getMosParkingListData(),
            error: ServerAgentError.emptyResponseData
        )
    }
    
    func test_getMosParkingListData_shouldFailOnServerError() async throws {
        
        let sut = makeSUT(serverStubs: [
            .mosParking(.failure(.unexpectedResponseStatus(-1)))
        ])
        
        try await assertThrowsAsNSError(
            _ = try await sut.getMosParkingListData(),
            error: ServerAgentError.corruptedData(ServerAgentError.unexpectedResponseStatus(-1))
        )
    }
    
    func test_getMosParkingListData_shouldFailOnNilData() async throws {
        
        let sut = makeSUT(serverStubs: [
            .mosParking(.success(data: nil))
        ])
        
        try await assertThrowsAsNSError(
            _ = try await sut.getMosParkingListData(),
            error: ServerAgentError.serverStatus(.ok, errorMessage: nil)
        )
    }
    
    func test_getMosParkingListData_shouldReturnData_emptySerial() async throws {
        
        let sut = makeSUT(serverStubs: [
            .mosParking(.success(data: .test(serial: "")))
        ])
        
        let (serial, data) = try await sut.getMosParkingListData()
        
        XCTAssertNoDiff(serial, "")
        XCTAssertNoDiff(data, .test)
    }
    
    func test_getMosParkingListData_shouldReturnData_nonEmptySerial() async throws {
        
        let sut = makeSUT(serverStubs: [
            .mosParking(.success(data: .test(serial: "Abc")))
        ])
        
        let (serial, data) = try await sut.getMosParkingListData()
        
        XCTAssertNoDiff(serial, "Abc")
        XCTAssertNoDiff(data, .test)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        sessionAgent: SessionAgentProtocol = ActiveSessionAgentStub(),
        serverStubs: [ServerAgentTestStub.Stub]? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let serverAgent: ServerAgentProtocol = {
            if let serverStubs {
                return ServerAgentTestStub(serverStubs)
            } else {
                return ServerAgentEmptyMock()
            }
        }()
        let sut: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

extension ServerCommands.DictionaryController.GetMosParkingList.Response.MosParkingListData {
    
    static func test(serial: String) -> Self {
        
        .init(mosParkingList: .test, serial: serial)
    }
}

extension Array where Element == MosParkingData {
    
    static let test: Self = [
        .refill,
        .monthly20, .monthly21, .monthly22,
        .yearly23, .yearly24, .yearly25
    ]
}

extension MosParkingData {
    
    static let monthly20: Self = .test(groupName: "Месячная", value: 20)
    static let monthly21: Self = .test(default: nil, groupName: "Месячная", value: 21)
    static let monthly22: Self = .test(groupName: "Месячная", value: 22)
    
    static let yearly23: Self = .test(default: true, groupName: "Годовая", value: 23)
    static let yearly24: Self = .test(groupName: "Годовая", value: 24)
    static let yearly25: Self = .test(default: nil, groupName: "Годовая", value: 25)
    
    static func test(
        default: Bool? = false,
        groupName: String,
        md5hash: String? = nil,
        svgImage: SVGImageData? = nil,
        text: String? = nil,
        value: Int
    ) -> Self {
        
        .init(
            default: `default`,
            groupName: groupName,
            md5hash: md5hash,
            svgImage: svgImage,
            text: text ?? "\(groupName)-\(value)",
            value: "\(value)"
        )
    }
}
