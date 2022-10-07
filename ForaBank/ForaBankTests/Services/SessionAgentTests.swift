//
//  SessionAgentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 25.08.2022.
//

import XCTest
@testable import ForaBank

class SessionAgentTests: XCTestCase {

    func testSessionTimeRemain_Greater_Zero() throws {

        // given
        let now = Date().timeIntervalSinceReferenceDate
        let sessionDuration: TimeInterval = 300
        let lastNetworkActivityTime = now - 100

        //when
        let result = SessionAgent.sessionTimeRemain(currentTime: now, lastNetworkActivityTime: lastNetworkActivityTime, sessionDuration: sessionDuration)

        //then
        XCTAssertEqual(result, 200, accuracy: .ulpOfOne)
    }

    func testSessionTimeRemain_Zero() throws {

        // given
        let now = Date().timeIntervalSinceReferenceDate
        let sessionDuration: TimeInterval = 300
        let lastNetworkActivityTime = now - 500

        //when
        let result = SessionAgent.sessionTimeRemain(currentTime: now, lastNetworkActivityTime: lastNetworkActivityTime, sessionDuration: sessionDuration)

        //then
        XCTAssertEqual(result, 0, accuracy: .ulpOfOne)
    }

    func testIsSessionExtendRequired_True() throws {

        // given
        let now = Date().timeIntervalSinceReferenceDate
        let sessionDuration: TimeInterval = 300
        let lastNetworkActivityTime = now - 290
        let lastUserActivityTime: TimeInterval = now - 10
        let sessionExtentThreshold: Double = 0.7
        let sessionTimeRemain: TimeInterval = 10

        //when
        let result = SessionAgent.isSessionExtendRequired(sessionTimeRemain: sessionTimeRemain, sessionDuration: sessionDuration, sessionExtentThreshold: sessionExtentThreshold, lastNetworkActivityTime: lastNetworkActivityTime, lastUserActivityTime: lastUserActivityTime)

        //then
        XCTAssertTrue(result)
    }

    func testIsSessionExtendRequired_False() throws {

        // given
        let now = Date().timeIntervalSinceReferenceDate
        let sessionDuration: TimeInterval = 300
        let lastNetworkActivityTime = now - 50
        let lastUserActivityTime: TimeInterval = now - 10
        let sessionExtentThreshold: Double = 0.7
        let sessionTimeRemain: TimeInterval = 250

        //when
        let result = SessionAgent.isSessionExtendRequired(sessionTimeRemain: sessionTimeRemain, sessionDuration: sessionDuration, sessionExtentThreshold: sessionExtentThreshold, lastNetworkActivityTime: lastNetworkActivityTime, lastUserActivityTime: lastUserActivityTime)

        //then
        XCTAssertFalse(result)
    }
}
