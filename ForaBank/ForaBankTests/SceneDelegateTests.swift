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
    
    func test_connectScene_shouldSetWindow() throws {
        
        let sceneDelegate = try connectScene()
        
        XCTAssertNotNil(sceneDelegate.window)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SceneDelegate
    
    private func makeSUT(
        rootComposer: RootComposer = ModelRootComposer.immediate(),
        featureFlags: FeatureFlags = .active,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(rootComposer: rootComposer, featureFlags: featureFlags)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class UIWindowSpy: UIWindow {
        
        var makeKeyAndVisibleCallCount = 0
        
        override func makeKeyAndVisible() {
            
            makeKeyAndVisibleCallCount = 1
        }
    }
    
    private func connectScene(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> SceneDelegate {
        
        let sceneDelegate = makeSUT()
        
        let scene: UIWindowScene = try make()
        let session: UISceneSession = try make()
        let options: UIScene.ConnectionOptions = try make()
        
        sceneDelegate.scene(scene, willConnectTo: session, options: options)
        
        return sceneDelegate
    }
}
