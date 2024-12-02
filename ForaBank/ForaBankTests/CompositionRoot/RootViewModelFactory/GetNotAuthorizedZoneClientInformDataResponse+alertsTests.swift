//
//  GetNotAuthorizedZoneClientInformDataResponse+alertsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.12.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class GetNotAuthorizedZoneClientInformDataResponse_alertsTests: XCTestCase {
    
    func test_shouldReturnNilOnFailure() {
        
        XCTAssertNil(makeFailure().alerts)
    }
    
    func test_shouldReturnEmptyOnEmpty() {
        
        let response: Result = .success(makeResponse())
        
        XCTAssertNoDiff(response.alerts?.informAlerts, [])
        XCTAssertNoDiff(response.alerts?.updateAlert, nil)
    }
    
//    func test_shouldReturnWithUpdateAlert() {
//        
//        let update = makeUpdate()
//        let response: Result = .success(makeResponse(
//            list: [makeData(update: update)]
//        ))
//        
//        XCTAssertNoDiff(response.alerts?.informAlerts, [])
//        XCTAssertNoDiff(response.alerts?.updateAlert, .init(id: <#T##UUID#>, title: <#T##String#>, text: <#T##String#>, link: <#T##String?#>, version: <#T##String?#>, actionType: <#T##ClientInformActionType#>))
//        XCTAssertNoDiff(response.alerts?.updateAlert?.title, update.
//    }
    
    func test_shouldReturnListOfOne() {
        
        XCTFail()
    }
    
    func test_shouldReturnListOfTwo() {
        
        XCTFail()
    }
    
    // MARK: - Helpers
    
    private typealias Result = Swift.Result<SUT, Error>
    private typealias SUT = RemoteServices.ResponseMapper.GetNotAuthorizedZoneClientInformDataResponse
    private typealias InformData = RemoteServices.ResponseMapper.GetNotAuthorizedZoneClientInformData
    private typealias Update = RemoteServices.ResponseMapper.GetNotAuthorizedZoneClientInformData.Update
    
    private func makeFailure() -> Result {
        
        return .failure(anyError())
    }
    
    private func makeResponse(
        list: [InformData] = [],
        serial: String = anyMessage()
    ) -> SUT {
        
        return .init(list: list, serial: serial)
    }
    
    private func makeData(
        authBlocking: Bool = true,
        title: String = anyMessage(),
        text: String = anyMessage(),
        update: Update? = nil
    ) -> InformData {
        
        return .init(authBlocking: authBlocking, title: title, text: text, update: update)
    }
    
    private func makeUpdate(
        type: String = anyMessage(),
        platform: String = anyMessage(),
        version: String = anyMessage(),
        link: String = anyMessage()
    ) -> Update {
        
        return .init(type: type, platform: platform, version: version, link: link)
    }
}
