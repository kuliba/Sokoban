//
//  SavingsAccountComposerTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 05.12.2024.
//

@testable import ForaBank
import XCTest

final class SavingsAccountComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, _, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }

    func test_init_shouldCallLoadOnLoad() {
        
        let (sut, _, spy) = makeSUT()
        
        sut.compose().content.event(.load)
        
        XCTAssertEqual(spy.callCount, 1)
        XCTAssertNotNil(sut)
    }
    
    func test___should___() {
        
        let (sut, binder, _) = makeSUT()
        
        binder.content.event(.loaded(.test))
        
        
    }

    // MARK: - Helpers
    
    private typealias SUT = SavingsAccountComposer
    private typealias Binder = SavingsAccountDomain.Binder
    private typealias LoadLandingSpy = Spy<String, Result<SavingsAccountDomain.Landing, SavingsAccountDomain.ContentError>, Never>
    
    private typealias State = SavingsAccountDomain.FlowState
    private typealias Event = SavingsAccountDomain.FlowEvent
    private typealias Effect = SavingsAccountDomain.FlowEffect

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        binder: Binder,
        loadLandingSpy: LoadLandingSpy
    ) {
        let loadLandingSpy = LoadLandingSpy()
        let sut = SUT(
            nanoServices: .init(
                loadLanding: loadLandingSpy.process(_:completion:),
                orderAccount: {_ in }),
            scheduler: .immediate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loadLandingSpy, file: file, line: line)
        
        return (sut, sut.compose(), loadLandingSpy)
    }
}

private extension SavingsAccountDomain.Landing {
    
    static let test: Self = .init(
        theme: "theme",
        name: "name",
        marketing: .init(labelTag: "labelTag", imageLink: "imageLink", params: [ "param1", "param2" ]),
        advantages: [ .init(iconMd5hash: "iconMd5hash", title: "title", subtitle: "subtitle")],
        basicConditions: [.init(iconMd5hash: "icon", title: "title")],
        questions: [ .init(question: "question", answer: "answer")]
    )
}
