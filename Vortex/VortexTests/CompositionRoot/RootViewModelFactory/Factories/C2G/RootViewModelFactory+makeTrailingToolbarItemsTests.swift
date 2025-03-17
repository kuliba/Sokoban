//
//  RootViewModelFactory+makeTrailingToolbarItemsTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.02.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeTrailingToolbarItemsTests: RootViewModelFactoryTests {
    
    func test_shouldDeliverOneButtonWithIcon() {
        
        let sut = makeSUT().sut
        
        XCTAssertEqual(sut.makeTrailingToolbarItems(action: { _ in }).map(\.icon), [.ic24Bell])
    }
    
    func test_shouldDeliverOneButtonWithNotificationsAction() {
        
        let sut = makeSUT().sut
        let spy = ActionSpy(stubs: [()])
        let first = sut.makeTrailingToolbarItems(action: spy.call).first
        first?.action()
        
        XCTAssertNoDiff(spy.payloads, [.notifications])
    }
    
    // MARK: - Helpers
    
    typealias ActionSpy = CallSpy<MainViewModelAction.Toolbar, Void>
}
