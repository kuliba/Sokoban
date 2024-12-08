//
//  Model+SbpPayTests.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 17.08.2023.
//

@testable import Vortex
import XCTest

final class Model_SbpPayTests: XCTestCase {
    
    func test_processTokenIntent_shouldReturnSpyProcessToken_onProcessToken() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertNoDiff(
            spy.processSbpPayTokens.map(\.testProcessToken),
            []
        )
        
        sut.processTokenIntent(
            .init(
                accountId: "accountId",
                tokenIntent: "tokenIntent",
                result: .success
            )
        )
        
        XCTAssertNoDiff(
            spy.processSbpPayTokens.map(\.testProcessToken),[
                .init(
                    endpoint: "/sbpay/processTokenIntent",
                    tokenIntentId: "tokenIntent"
                )
            ]
        )
    }
    
    func test_processTokenIntent_shouldReturnSpyProcessToken_onSendActionProcessIntent() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertNoDiff(
            spy.processSbpPayTokens.map(\.testProcessToken),
            []
        )
        
        sut.action.send(ModelAction.SbpPay.ProcessTokenIntent.Request(
            accountId: "accountId",
            tokenIntent: "tokenIntent",
            result: .success
        ))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNoDiff(
            spy.processSbpPayTokens.map(\.testProcessToken),[
                .init(
                    endpoint: "/sbpay/processTokenIntent",
                    tokenIntentId: "tokenIntent"
                )
            ]
        )
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Model,
        spy: ServerAgentSpy
    ) {
        let spy = ServerAgentSpy()
        let sut: Model = .mockWithEmptyExcept(
            sessionAgent: ActiveSessionAgentStub(),
            serverAgent: spy
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}

private extension ServerCommands.SbpPayController.ProcessToken {
    
    var testProcessToken: TestProcessToken {
        
        .init(
            endpoint: endpoint,
            tokenIntentId: payload?.tokenIntentId
        )
    }
    
    struct TestProcessToken: Equatable {
        
        let endpoint: String
        let tokenIntentId: String?
    }
}
