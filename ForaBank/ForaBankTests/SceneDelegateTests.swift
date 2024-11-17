//
//  SceneDelegateTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.11.2024.
//

@testable import ForaBank
import XCTest

final class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_shouldSetWindowAsKeyAndVisible() {
        
        let sut = makeSUT()
        let window = UIWindowSpy()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
    }
    
    func test_configureWindow_shouldConfigureRootViewController() {
        
        let sut = makeSUT()
        sut.window = UIWindowSpy()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootController = root as? RootViewHostingViewController
        
        XCTAssertNotNil(rootController, "Expected RootViewHostingViewController as root, got \(String(describing: root)) instead.")
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SceneDelegate
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class UIWindowSpy: UIWindow {
        
        var makeKeyAndVisibleCallCount = 0
        
        override func makeKeyAndVisible() {
            
            makeKeyAndVisibleCallCount = 1
        }
    }
}
