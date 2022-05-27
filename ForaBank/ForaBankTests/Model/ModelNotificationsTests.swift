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
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email),
                                            .init(date: date + TimeInterval(2),
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push),
                                            .init(date: date + TimeInterval(3),
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email)]
        
        let update: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email),
                                           .init(date: date + TimeInterval(4),
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .push),
                                           .init(date: date + TimeInterval(5),
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_e",
                                                 type: .email)]
        
        
        let testResult: [NotificationData] = [.init(date: date + TimeInterval(1),
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS",
                                                    type: .email),
                                              .init(date: date + TimeInterval(2),
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push),
                                              .init(date: date + TimeInterval(3),
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email),
                                              .init(date: date + TimeInterval(4),
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .push),
                                              .init(date: date + TimeInterval(5),
                                                    title: "Cmc",
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
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email),
                                            .init(date: date,
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push),
                                            .init(date: date,
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email)]
        
        let update: [NotificationData] = [ .init(date: date,
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email),
                                           .init(date: date,
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_s",
                                                 type: .push),
                                           .init(date: date,
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .email)]
        
        
        let testResult: [NotificationData] = [.init(date: date,
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS",
                                                    type: .email),
                                              .init(date: date,
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push),
                                              .init(date: date,
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email)
        ]
        
        // when
        let result = Model.dictinaryNotificationReduce(current: current, update: update)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 3)
      //  XCTAssertEqual(result, testResult)
    }
    
    func testNotificationsNotEqualFalse() throws {
        
        // given
        let current: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email),
                                            .init(date: date + TimeInterval(2),
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push),
                                            .init(date: date + TimeInterval(3),
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email)]
        
        let update: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email),
                                           .init(date: date + TimeInterval(4),
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .push),
                                           .init(date: date + TimeInterval(5),
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_e",
                                                 type: .email)]
        
        
        let testResult: [NotificationData] = [
                                              .init(date: date + TimeInterval(2),
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push),
                                              .init(date: date + TimeInterval(3),
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email),
                                              .init(date: date + TimeInterval(4),
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .push),
                                              .init(date: date + TimeInterval(5),
                                                    title: "Cmc",
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

    func testNotificationsExpected() throws {
        
        let current: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                         title: "Cmc",
                                                         state: .delivered ,
                                                         text: "SMS",
                                                         type: .email),
                                                   .init(date: date + TimeInterval(2),
                                                         title: "Cmc",
                                                         state: .delivered ,
                                                         text: "SMS_s",
                                                         type: .push)
                                                   ]
        
        let update: [NotificationData] = [ .init(date: date + TimeInterval(1),
                                                        title: "Cmc",
                                                         state: .delivered ,
                                                         text: "SMS",
                                                         type: .email),
                                                   .init(date: date + TimeInterval(3),
                                                         title: "Cmc",
                                                         state: .delivered ,
                                                         text: "PUSH",
                                                         type: .push)
                                                   ]
        
        // when
        let expected = Model.dictinaryNotificationReduce(current: current,
                                                       update: update)
        
        // then
        XCTAssertEqual(expected.count, 3)
    }
}
