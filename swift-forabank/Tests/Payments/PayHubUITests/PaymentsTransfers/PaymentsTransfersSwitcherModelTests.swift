//
//  ProfileSwitcherModelTests.swift
//
//
//  Created by Igor Malyarov on 29.08.2024.
//

import Combine
import CombineSchedulers
import PayHubUI
import XCTest

final class ProfileSwitcherModelTests: XCTestCase {
    
    func test_init_shouldSetStateToPersonal() {
        
        let personal = makePersonal()
        let (sut, _, spy) = makeSUT(corporate: makeCorporate(), personal: personal)
        
        XCTAssertNoDiff(spy.values, [.personal(personal)])
        XCTAssertNotNil(sut)
    }
    
    func test_shouldSetStateOnIsCorporateOnlyValueChange() {
        
        let (corporate, personal) = (makeCorporate(), makePersonal())
        let (_, subject, spy) = makeSUT(corporate: corporate, personal: personal)
        
        subject.send(true)
        
        XCTAssertNoDiff(spy.values, [
            .personal(personal),
            .corporate(corporate)
        ])
        
        subject.send(false)
        
        XCTAssertNoDiff(spy.values, [
            .personal(personal),
            .corporate(corporate),
            .personal(personal),
        ])
    }
    
    func test_shouldNotSetStateTwiceOnSameValue_false() {
        
        let (corporate, personal) = (makeCorporate(), makePersonal())
        let (_, subject, spy) = makeSUT(corporate: corporate, personal: personal)
        
        subject.send(false)
        
        XCTAssertNoDiff(spy.values, [
            .personal(personal),
            .personal(personal),
        ])
        
        subject.send(false)
        
        XCTAssertNoDiff(spy.values, [
            .personal(personal),
            .personal(personal),
        ])
    }
    
    func test_shouldNotSetStateTwiceOnSameValue_true() {
        
        let (corporate, personal) = (makeCorporate(), makePersonal())
        let (_, subject, spy) = makeSUT(corporate: corporate, personal: personal)
        
        subject.send(true)
        
        XCTAssertNoDiff(spy.values, [
            .personal(personal),
            .corporate(corporate)
        ])
        
        subject.send(true)
        
        XCTAssertNoDiff(spy.values, [
            .personal(personal),
            .corporate(corporate),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ProfileSwitcherModel<Corporate, Personal>
    private typealias Subject = PassthroughSubject<Bool, Never>
    private typealias StateSpy = ValueSpy<SUT.State>
    
    private func makeSUT(
        corporate: Corporate? = nil,
        personal: Personal? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        subject: Subject,
        stateSpy: StateSpy
    ) {
        let subject = Subject()
        let sut = SUT(
            isCorporateOnly: subject.eraseToAnyPublisher(),
            corporate: corporate ?? makeCorporate(),
            personal: personal ?? makePersonal(),
            scheduler: .immediate
        )
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, subject, spy)
    }
    
    private struct Corporate: Equatable {
        
        let value: String
    }
    
    private func makeCorporate(
        _ value: String = anyMessage()
    ) -> Corporate {
        
        return .init(value: value)
    }
    
    private struct Personal: Equatable {
        
        let value: String
    }
    
    private func makePersonal(
        _ value: String = anyMessage()
    ) -> Personal {
        
        return .init(value: value)
    }
}
