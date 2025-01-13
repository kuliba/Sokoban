//
//  GetShowcaseDomainEffectHandlerTests.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

@testable import CollateralLoanLandingGetShowcaseUI
import XCTest
import Combine

final class GetShowcaseDomainEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallLoadOnInit() {
        
        let (_, loadSpy) = makeSUT()
        XCTAssert(loadSpy.callCount == 0)
    }

    func test_handleEffect_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loadSpy) = makeSUT()
        
        expect(
            sut,
            with: .load,
            toDeliver: .loaded(.failure(.init())),
            on: {
                
                loadSpy.complete(with: .failure(.init()))
            }
        )
    }

    func test_handleEffect_shouldDeliverSuccessOnLoadSuccess() {
        
        let (sut, loadSpy) = makeSUT()
        
        expect(
            sut,
            with: .load,
            toDeliver: .loaded(.success(.stub)),
            on: {
                
                loadSpy.complete(with: .success(.stub))
            }
        )
    }

    func test_handleEffect_shouldCallLoadOnLoadEffect() {
        
        let (sut, loadSpy) = makeSUT()
        
        sut.handleEffect(.load) { _ in }
        
        XCTAssertEqual(loadSpy.callCount, 1)

    }
    
    // MARK: - Helpers
    
    private typealias SUT = GetShowcaseDomain.EffectHandler
    private typealias Load = (@escaping Completion) -> Void
    private typealias Completion = (GetShowcaseDomain.Result) -> Void
    private typealias LoadSpy = Spy<Void, GetShowcaseDomain.Result>
    
    private func makeSUT() -> (
        sut: SUT,
        loadSpy: LoadSpy
    ) {
        let loadSpy = LoadSpy()
        let sut = SUT(load: loadSpy.process(completion:))

        return (sut, loadSpy)
    }
    
    func expect(
        _ sut: GetShowcaseDomain.EffectHandler,
        with effect: GetShowcaseDomain.Effect,
        toDeliver expectedEvent: GetShowcaseDomain.Event,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) { receivedEvent in
            
            XCTAssertNoDiff(
                receivedEvent,
                expectedEvent,
                "\nExpected \(expectedEvent), but got \(receivedEvent) instead.",
                file: file, line: line
            )
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}

extension CollateralLoanLandingGetShowcaseData {

    static let stub = Self(
        products: [Product](repeating: .makeStub(), count: .random(in: 0..<10))
    )
}

fileprivate extension CollateralLoanLandingGetShowcaseData.Product {
    
    static func makeStub(
        theme: Theme = .random,
        title: String = anyMessage(),
        image: String = anyMessage(),
        keyMarketingParams: KeyMarketingParams = .makeAny(),
        featuresHeader: String = anyMessage()
    ) -> Self {
        
        typealias List = CollateralLoanLandingGetShowcaseData.Product.Features.List
        
        let list = [List](repeating: .init(bullet: .random(), text: anyMessage()), count: .random(in: 0..<10))
        
        return .init(
            theme: theme,
            name: title,
            terms: anyMessage(),
            landingId: anyMessage(),
            image: image,
            keyMarketingParams: keyMarketingParams,
            features: .init(
                header: featuresHeader,
                list: list
            )
        )
    }
}

fileprivate extension CollateralLoanLandingGetShowcaseData.Product.KeyMarketingParams {

    static func makeAny() -> Self {
        .init(
            rate: anyMessage(),
            amount: anyMessage(),
            term: anyMessage()
        )
    }
}

fileprivate extension CollateralLoanLandingGetShowcaseData.Product.Theme {
    
    static var random: Self {
        
        let values: [Self] = [.gray, .white, .unknown]
        let randomIndex = Int.random(in: 0..<values.count)
        return values[randomIndex]
    }
    
    static var validRandom: Self {

        let values: [Self] = [.gray, .white]
        let randomIndex = Int.random(in: 0..<values.count)
        return values[randomIndex]
    }
}
