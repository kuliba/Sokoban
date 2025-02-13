//
//  RootViewModelFactory+makeTrailingToolbarItemsTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.02.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeTrailingToolbarItemsTests: RootViewModelFactoryTests {
    
    // MARK: - inactive
    
    func test_shouldDeliverOneButtonWithIcon_onInactiveFlag() {
        
        let sut = makeSUT().sut
        
        let makeTrailingToolbarItems = sut.makeTrailingToolbarItems(.inactive)
        
        XCTAssertEqual(makeTrailingToolbarItems({ _ in }).map(\.icon), [.ic24Bell])
    }
    
    func test_shouldDeliverOneButtonWithNotificationsAction_onInactiveFlag() {
        
        let sut = makeSUT().sut
        let spy = ActionSpy(stubs: [()])
        
        let makeTrailingToolbarItems = sut.makeTrailingToolbarItems(.inactive)
        let first = makeTrailingToolbarItems(spy.call).first
        first?.action()
        
        XCTAssertNoDiff(spy.payloads, [.notifications])
    }
    
    // MARK: - active
    
    func test_shouldDeliverTwoButtonsWithIcon_onActiveFlag() {
        
        let sut = makeSUT().sut
        
        let makeTrailingToolbarItems = sut.makeTrailingToolbarItems(.active)
        
        XCTAssertEqual(makeTrailingToolbarItems({ _ in }).map(\.icon), [.ic24BarcodeScanner2, .ic24Bell])
    }
    
    func test_shouldDeliverTwoButtonsFirstWithTitle_onActiveFlag() {
        
        let sut = makeSUT().sut
        
        let makeTrailingToolbarItems = sut.makeTrailingToolbarItems(.active)
        
        XCTAssertEqual(makeTrailingToolbarItems({ _ in }).map(\.title), ["Сканировать", ""])
    }
    
    func test_shouldDeliverFirstButtonWithScanQRsAction_onActiveFlag() {
        
        let sut = makeSUT().sut
        let spy = ActionSpy(stubs: [()])
        
        let makeTrailingToolbarItems = sut.makeTrailingToolbarItems(.active)
        let first = makeTrailingToolbarItems(spy.call).first
        first?.action()
        
        XCTAssertNoDiff(spy.payloads, [.scanQR])
    }
    
    func test_shouldDeliverSecondButtonWithNotificationsAction_onActiveFlag() {
        
        let sut = makeSUT().sut
        let spy = ActionSpy(stubs: [()])
        
        let makeTrailingToolbarItems = sut.makeTrailingToolbarItems(.active)
        let last = makeTrailingToolbarItems(spy.call).last
        last?.action()
        
        XCTAssertNoDiff(spy.payloads, [.notifications])
    }
    
    // MARK: - Helpers
    
    typealias ActionSpy = CallSpy<MainViewModelAction.Toolbar, Void>
}
