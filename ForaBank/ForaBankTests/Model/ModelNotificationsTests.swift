//
//  ModelNotificationsTests.swift
//  ForaBankTests
//
//  Created by Константин Савялов on 26.04.2022.
//

import XCTest
@testable import ForaBank

class ModelNotificationsTests: XCTestCase {
    
    let date = Date()
    
    func testNotificationsNotEqual() throws {
        
        // given
        let current: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email),
                                            .init(date: date + TimeInterval(2),
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push),
                                            .init(date: date + TimeInterval(3),
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email)]
        
        let update: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email),
                                           .init(date: date + TimeInterval(4),
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .push),
                                           .init(date: date + TimeInterval(5),
                                                 state: .delivered ,
                                                 text: "SMS_e",
                                                 type: .email)]
        
        
        let testResult: [NotificationData] = [.init(date: date + TimeInterval(1),
                                                    state: .delivered ,
                                                    text: "SMS",
                                                    type: .email),
                                              .init(date: date + TimeInterval(2),
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push),
                                              .init(date: date + TimeInterval(3),
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email),
                                              .init(date: date + TimeInterval(4),
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .push),
                                              .init(date: date + TimeInterval(5),
                                                    state: .delivered ,
                                                    text: "SMS_e",
                                                    type: .email)
        ]
        
        // when
        let result = Model.dictinaryNotificationReduce(current: current, update: update)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result, testResult)
        XCTAssertNotEqual(current, update)
    }
    
    func testNotificationsIsEqual() throws {
        
        // given
        let current: [NotificationData] = [ .init(date: date,
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email),
                                            .init(date: date,
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push),
                                            .init(date: date,
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email)]
        
        let update: [NotificationData] = [ .init(date: date,
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email),
                                           .init(date: date,
                                                 state: .delivered ,
                                                 text: "SMS_s",
                                                 type: .push),
                                           .init(date: date,
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .email)]
        
        
        let testResult: [NotificationData] = [.init(date: date,
                                                    state: .delivered ,
                                                    text: "SMS",
                                                    type: .email),
                                              .init(date: date,
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push),
                                              .init(date: date,
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email)
        ]
        
        // when
        let result = Model.dictinaryNotificationReduce(current: current, update: update)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result, testResult)
    }
    
    func testNotificationsNotEqualFalse() throws {
        
        // given
        let current: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email),
                                            .init(date: date + TimeInterval(2),
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push),
                                            .init(date: date + TimeInterval(3),
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email)]
        
        let update: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email),
                                           .init(date: date + TimeInterval(4),
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .push),
                                           .init(date: date + TimeInterval(5),
                                                 state: .delivered ,
                                                 text: "SMS_e",
                                                 type: .email)]
        
        
        let testResult: [NotificationData] = [
                                              .init(date: date + TimeInterval(2),
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push),
                                              .init(date: date + TimeInterval(3),
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email),
                                              .init(date: date + TimeInterval(4),
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .push),
                                              .init(date: date + TimeInterval(5),
                                                    state: .delivered ,
                                                    text: "SMS_e",
                                                    type: .email)
        ]
        
        // when
        let result = Model.dictinaryNotificationReduce(current: current, update: update)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 5)
        XCTAssertNotEqual(result, testResult)
    }


}
