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
        let current: [NotificationData] = [ .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email,
                                                  date: date + TimeInterval(1)),
                                            .init(
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push,
                                                  date: date + TimeInterval(2)),
                                            .init(
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email,
                                                  date: date + TimeInterval(3))]
        
        let update: [NotificationData] = [ .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email,
                                                 date: date + TimeInterval(1)),
                                           .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .push,
                                                 date: date + TimeInterval(4)),
                                           .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_e",
                                                 type: .email,
                                                 date: date + TimeInterval(5))]
        
        
        let testResult: [NotificationData] = [.init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS",
                                                    type: .email,
                                                    date: date + TimeInterval(1)),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push,
                                                    date: date + TimeInterval(2)),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email,
                                                    date: date + TimeInterval(3)),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .push,
                                                    date: date + TimeInterval(4)),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_e",
                                                    type: .email,
                                                    date: date + TimeInterval(5))
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
        let current: [NotificationData] = [ .init(
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email,
                                                  date: date),
                                            .init(
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push,
                                                  date: date),
                                            .init(
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email,
                                                  date: date)]
        
        let update: [NotificationData] = [ .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email,
                                                 date: date),
                                           .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_s",
                                                 type: .push,
                                                 date: date),
                                           .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .email,
                                                 date: date)]
        
        
        let testResult: [NotificationData] = [.init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS",
                                                    type: .email,
                                                    date: date),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push,
                                                    date: date),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email,
                                                    date: date)
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
        let current: [NotificationData] = [ .init(
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email,
                                                  date: date + TimeInterval(1)),
                                            .init(
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push,
                                                  date: date + TimeInterval(2)),
                                            .init(
                                                  title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email,
                                                  date: date + TimeInterval(3))]
        
        let update: [NotificationData] = [ .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email,
                                                 date: date + TimeInterval(1)),
                                           .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .push,
                                                 date: date + TimeInterval(4)),
                                           .init(
                                                 title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_e",
                                                 type: .email,
                                                 date: date + TimeInterval(5))]
        
        
        let testResult: [NotificationData] = [
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push,
                                                    date: date + TimeInterval(2)),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email,
                                                    date: date + TimeInterval(3)),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .push,
                                                    date: date + TimeInterval(4)),
                                              .init(
                                                    title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_e",
                                                    type: .email,
                                                    date: date + TimeInterval(5))
        ]
        
        // when
        let result = Model.dictinaryNotificationReduce(current: current, update: update)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 5)
        XCTAssertNotEqual(result, testResult)
    }

    func testNotificationsExpected() throws {
        
        let current: [NotificationData] = [ .init(
                                                         title: "Cmc",
                                                         state: .delivered ,
                                                         text: "SMS",
                                                         type: .email,
                                                         date: date + TimeInterval(1)),
                                                   .init(
                                                         title: "Cmc",
                                                         state: .delivered ,
                                                         text: "SMS_s",
                                                         type: .push,
                                                         date: date + TimeInterval(2))
                                                   ]
        
        let update: [NotificationData] = [ .init(
                                                        title: "Cmc",
                                                         state: .delivered ,
                                                         text: "SMS",
                                                         type: .email,
                                                        date: date + TimeInterval(1)),
                                                   .init(
                                                         title: "Cmc",
                                                         state: .delivered ,
                                                         text: "PUSH",
                                                         type: .push,
                                                         date: date + TimeInterval(3))
                                                   ]
        
        // when
        let expected = Model.dictinaryNotificationReduce(current: current,
                                                       update: update)
        
        // then
        XCTAssertEqual(expected.count, 3)
    }
}
