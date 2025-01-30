//
//  RootViewModelFactory+getMeToMeNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 30.01.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_getMeToMeNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - alert
    
    func test_alert_shouldDeliverAlert() {
        
        let alert = anyMessage()
        
        expect(.alert(alert), toDeliver: .alert(alert))
    }
    
    // MARK: - meToMe
    
    func test_meToMe_shouldDeliverFailureAlert_onMissingMeToMeProduct() {
        
        expect(.meToMe, toDeliver: .alert("Ошибка создания платежа между своими."))
    }
    
    func test_meToMe_shouldDeliverMeToMe_onMeToMeProduct() throws {
        
        let model = try makeModelWithMeToMeProduct()
        let sut = makeSUT(model: model).sut
        
        expect(sut: sut, .meToMe, toDeliver: .meToMe)
    }
    
    // MARK: - successMeToMe
    
    func test_successMeToMe_shouldDeliverSuccessMeToMe() {
        
        let success = makeSuccess()
        
        expect(.successMeToMe(success), toDeliver: .successMeToMe(.init(success.model)))
    }
    
    // MARK: - Helpers
    
    private typealias Domain = Vortex.MeToMeDomain
    
    private func makeSuccess() -> Node<PaymentsSuccessViewModel> {
        
        return .init(
            model: .init(
                model: .mockWithEmptyExcept(),
                sections: []
            ),
            cancellables: []
        )
    }
    
    private func makeModelWithMeToMeProduct(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Model {
        
        let model: Model = .mockWithEmptyExcept()
        try model.addMeToMeProduct(file: file, line: line)
        
        return model
    }
    
    private func expect(
        sut: SUT? = nil,
        _ select: Domain.Select,
        toDeliver expectedNavigation: EquatableNavigation,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for get navigation completion")
        
        sut.getNavigation(
            select: select,
            notify: { _ in }
        ) {
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func equatable(
        _ navigation: Domain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .alert(alert):
            return .alert(alert)
            
        case .meToMe:
            return .meToMe
            
        case let .successMeToMe(node):
            return .successMeToMe(.init(node.model))
        }
    }
    
    // TODO: improve, but need to control objects creation => SUT needs a dependency
    enum EquatableNavigation: Equatable {
        
        case alert(String)
        case meToMe
        case successMeToMe(ObjectIdentifier)
    }
}
