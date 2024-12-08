//
//  GetNotAuthorizedZoneClientInformDataResponse+alertsTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 02.12.2024.
//

@testable import Vortex
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
    
    func test_shouldReturnWithUpdateAlert() {
        
        let update = makeUpdate()
        let response: Result = .success(makeResponse(
            list: [makeData(update: update)]
        ))
        
        let updateResponse = response.alerts?.updateAlert

        XCTAssertNoDiff(updateResponse?.link, update.link)
        XCTAssertNoDiff(updateResponse?.version, update.version)
        XCTAssertNoDiff(updateResponse?.actionType, ClientInformActionType(updateType: update.type))
    }
    
    func test_shouldReturnListOfOne() {
        
        let informData = makeData()
        let response: Result = .success(makeResponse(
            list: [informData]
        ))
        
        let informResponse = response.alerts?.informAlerts
        
        XCTAssertNoDiff(informResponse?.first?.title, informData.title)
        
        XCTAssertEqual(informResponse?.count, 1)
    }
    
    func test_shouldReturnListOfTwo() {
        
        let firstInformData = makeData()
        let secondInformData = makeData()
        let response: Result = .success(makeResponse(
            list: [firstInformData, secondInformData]
        ))
        
        let informResponse = response.alerts?.informAlerts
        
        XCTAssertNoDiff(informResponse?[0].title, firstInformData.title)
        XCTAssertNoDiff(informResponse?[1].title, secondInformData.title)

        XCTAssertEqual(informResponse?.count, 2)
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
        authBlocking: Bool = false,
        title: String = anyMessage(),
        text: String = anyMessage(),
        update: Update? = nil
    ) -> InformData {
        
        return .init(authBlocking: authBlocking, title: title, text: text, update: update)
    }
    
    private func makeUpdate(
        type: String = "required",
        platform: String = anyMessage(),
        version: String = anyMessage(),
        link: String = anyMessage()
    ) -> Update {
        
        return .init(type: type, platform: platform, version: version, link: link)
    }
}
