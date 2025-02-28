//
//  ServerCommandsNotificationTests.swift
//  VortexTests
//
//  Created by Max Gribov on 03.02.2022.
//

import XCTest
@testable import Vortex

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
        
        let data = EmptyData()
        let expected = ServerCommands.NotificationController.ChangeNotificationStatus.Response(statusCode: .ok, errorMessage: "string", data: data)
        
        // when
        let result = try decoder.decode(ServerCommands.NotificationController.ChangeNotificationStatus.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    func testChangeNotificationStatus_Encoding() throws {
        
        let command = ServerCommands.NotificationController.ChangeNotificationStatus(token: "", payload: .init(eventId: "123456", cloudId: "", status: .delivered))
        
        let result = try encoder.encode(command.payload)
        
        try XCTAssertNoDiff(result.jsonDict(), [
            "eventId": "123456",
            "cloudId": "",
            "status":"DELIVERED"
        ])
    }
    
    //MARK: - GetNotifications
    
    func testGetNotifications_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetNotificationsResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let date = DateFormatter.iso8601.date(from: "2022-07-05T16:48:10.563Z")!
        let expected = ServerCommands.NotificationController.GetNotifications.Response(statusCode: .ok, errorMessage: "string", data: [.init(title: "Смс", state: .sent, text: "27.12.2022 18:22:58: Успешный вход в приложение", type: .push, date: date)])
        
        // when
        let result = try decoder.decode(ServerCommands.NotificationController.GetNotifications.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    func testGetNotifications_Parameters() throws {
        // given
        
        let command = ServerCommands.NotificationController.GetNotifications(token: "", offset: 100, limit: 200, types: [.push, .email, .sms], states: [.inProgress, .delivered, .sent])
        
        // then
        XCTAssertNotNil(command.parameters)
        XCTAssertEqual(command.parameters?.count, 8)
        
        XCTAssertEqual(command.parameters?[0].name, "offset")
        XCTAssertEqual(command.parameters?[1].name, "limit")
        XCTAssertEqual(command.parameters?[2].name, "notificationType")
        XCTAssertEqual(command.parameters?[3].name, "notificationType")
        XCTAssertEqual(command.parameters?[4].name, "notificationType")
        XCTAssertEqual(command.parameters?[5].name, "notificationState")
        XCTAssertEqual(command.parameters?[6].name, "notificationState")
        XCTAssertEqual(command.parameters?[7].name, "notificationState")
        
        XCTAssertEqual(command.parameters?[0].value, "100")
        XCTAssertEqual(command.parameters?[1].value, "200")
        XCTAssertEqual(command.parameters?[2].value, "PUSH")
        XCTAssertEqual(command.parameters?[3].value, "EMAIL")
        XCTAssertEqual(command.parameters?[4].value, "SMS")
        XCTAssertEqual(command.parameters?[5].value, "IN_PROGRESS")
        XCTAssertEqual(command.parameters?[6].value, "DELIVERED")
        XCTAssertEqual(command.parameters?[7].value, "SENT")
    }
    
}
