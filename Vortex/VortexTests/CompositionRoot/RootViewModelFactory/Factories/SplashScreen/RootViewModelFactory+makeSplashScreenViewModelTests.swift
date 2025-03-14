//
//  RootViewModelFactory+makeSplashScreenViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 14.03.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeSplashScreenViewModelTests: RootViewModelFactoryTests {
    
    func test_shouldSetSplashPhaseToHidden_onInactiveFlag() {
        
        let (sut, _,_) = makeSUT()
        let splash = sut.makeSplashScreenViewModel(flag: .init(.inactive))
        
        XCTAssertNoDiff(splash.state.phase, .hidden)
    }
    
    func test_shouldSetSplashPhaseToCover_onActiveFlag() {
        
        let (sut, _,_) = makeSUT()
        let splash = sut.makeSplashScreenViewModel(flag: .init(.active))
        
        XCTAssertNoDiff(splash.state.phase, .cover)
    }
}
