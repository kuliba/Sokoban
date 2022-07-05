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
    
    func testNotifications_Merge() throws {
        
        // given
        let current: [NotificationData] = [ .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email,
                                                  dateUtc: date + TimeInterval(1)),
                                            .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push,
                                                  dateUtc: date + TimeInterval(2)),
                                            .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email,
                                                  dateUtc: date + TimeInterval(3))]
        
        let update: [NotificationData] = [ .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email,
                                                 dateUtc: date + TimeInterval(1)),
                                           .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .push,
                                                 dateUtc: date + TimeInterval(4)),
                                           .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_e",
                                                 type: .email,
                                                 dateUtc: date + TimeInterval(5))]
        
        
        let testResult: [NotificationData] = [.init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS",
                                                    type: .email,
                                                    dateUtc: date + TimeInterval(1)),
                                              .init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push,
                                                    dateUtc: date + TimeInterval(2)),
                                              .init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email,
                                                    dateUtc: date + TimeInterval(3)),
                                              .init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .push,
                                                    dateUtc: date + TimeInterval(4)),
                                              .init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_e",
                                                    type: .email,
                                                    dateUtc: date + TimeInterval(5))]
        
        // when
        let result = Model.dictinaryNotificationReduce(current: current, update: update)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result, testResult)
        XCTAssertNotEqual(current, update)
    }
    
    func testNotifications_IsEqual_True() throws {
        
        // given
        let current: [NotificationData] = [ .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email,
                                                  dateUtc: date + TimeInterval(1)),
                                            .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push,
                                                  dateUtc: date + TimeInterval(2)),
                                            .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email,
                                                  dateUtc: date + TimeInterval(3))]
        
        let update: [NotificationData] = [ .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email,
                                                 dateUtc: date + TimeInterval(1)),
                                           .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_s",
                                                 type: .push,
                                                 dateUtc: date + TimeInterval(2)),
                                           .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .email,
                                                 dateUtc: date + TimeInterval(3))]
        
        
        let testResult: [NotificationData] = [ .init(title: "Cmc",
                                                     state: .delivered ,
                                                     text: "SMS",
                                                     type: .email,
                                                     dateUtc: date + TimeInterval(1)),
                                               .init(title: "Cmc",
                                                     state: .delivered ,
                                                     text: "SMS_s",
                                                     type: .push,
                                                     dateUtc: date + TimeInterval(2)),
                                               .init(title: "Cmc",
                                                     state: .delivered ,
                                                     text: "PUSH",
                                                     type: .email,
                                                     dateUtc: date + TimeInterval(3))]
        
        // when
        let result = Model.dictinaryNotificationReduce(current: current, update: update)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result, testResult)
    }
    
    func testNotifications_IsEqual_False() throws {
        
        // given
        let current: [NotificationData] = [ .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS",
                                                  type: .email,
                                                  dateUtc: date + TimeInterval(1)),
                                            .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "SMS_s",
                                                  type: .push,
                                                  dateUtc: date + TimeInterval(2)),
                                            .init(title: "Cmc",
                                                  state: .delivered ,
                                                  text: "PUSH",
                                                  type: .email,
                                                  dateUtc: date + TimeInterval(3))]
        
        let update: [NotificationData] = [ .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS",
                                                 type: .email,
                                                 dateUtc: date + TimeInterval(1)),
                                           .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "PUSH",
                                                 type: .push,
                                                 dateUtc: date + TimeInterval(4)),
                                           .init(title: "Cmc",
                                                 state: .delivered ,
                                                 text: "SMS_e",
                                                 type: .email,
                                                 dateUtc: date + TimeInterval(5))]
        
        
        let testResult: [NotificationData] = [.init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_s",
                                                    type: .push,
                                                    dateUtc: date + TimeInterval(2)),
                                              .init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .email,
                                                    dateUtc: date + TimeInterval(3)),
                                              .init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "PUSH",
                                                    type: .push,
                                                    dateUtc: date + TimeInterval(4)),
                                              .init(title: "Cmc",
                                                    state: .delivered ,
                                                    text: "SMS_e",
                                                    type: .email,
                                                    dateUtc: date + TimeInterval(5))]
        
        // when
        let result = Model.dictinaryNotificationReduce(current: current, update: update)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 5)
        XCTAssertNotEqual(result, testResult)
    }
}
