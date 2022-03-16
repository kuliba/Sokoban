//
//  ServerCommandsNotificationTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 03.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsNotificationTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsDictionaryTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let formatter = DateFormatter.dateAndTime

    //MARK: - ChangeNotificationStatus

    func testChangeNotificationStatus_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "ChangeNotificationStatusGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.NotificationController.ChangeNotificationStatus.Response(statusCode: .ok, errorMessage: "string", data: nil)
        
        // when
        let result = try decoder.decode(ServerCommands.NotificationController.ChangeNotificationStatus.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    func testChangeNotificationStatus_Encoding() throws {
        // given

        let command = ServerCommands.NotificationController.ChangeNotificationStatus(token: "", payload: .init(eventId: "123456", cloudId: "", status: .delivered))
        
        let expected = "{\"eventId\":\"123456\",\"cloudId\":\"\",\"status\":\"DELIVERED\"}"
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)

        // then
        XCTAssertEqual(resultString, expected)
    }

    
    //MARK: - GetNotifications
    
    func testGetNotifications_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetNotificationsResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = formatter.date(from: "27.12.2021 18:22:58")!
        let expected = ServerCommands.NotificationController.GetNotifications.Response(statusCode: .ok, errorMessage: "string", data: [.init(date: date, state: .sent, text: "27.12.2022 18:22:58: Успешный вход в приложение", type: .push)])
        
        // when
        let result = try decoder.decode(ServerCommands.NotificationController.GetNotifications.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    func testGetNotifications_Parameters() throws {
        // given
        
        let command = ServerCommands.NotificationController.GetNotifications(token: "", offset: 100, limit: 200, type: .push, state: .inProgress)
        
        // then
        XCTAssertNotNil(command.parameters)
        XCTAssertEqual(command.parameters?.count, 4)
        
        XCTAssertEqual(command.parameters?[0].name, "offset")
        XCTAssertEqual(command.parameters?[1].name, "limit")
        XCTAssertEqual(command.parameters?[2].name, "notificationType")
        XCTAssertEqual(command.parameters?[3].name, "notificationState")
        
        XCTAssertEqual(command.parameters?[0].value, "100")
        XCTAssertEqual(command.parameters?[1].value, "200")
        XCTAssertEqual(command.parameters?[2].value, "PUSH")
        XCTAssertEqual(command.parameters?[3].value, "IN_PROGRESS")
    }
    
}
