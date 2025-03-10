//
//  RootViewModelFactory+composeEphemeralLoadersTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 09.03.2025.
//

import SerialComponents
@testable import Vortex
import XCTest

final class RootViewModelFactory_composeEphemeralLoadersTests: RootViewModelFactoryTests {
    
    func test_shouldNotCallRemote_onCreation() {
        
        let (load, reload, spy) = composeEphemeralLoaders()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(load)
        XCTAssertNotNil(reload)
    }
    
    // MARK: - load
    
    func test_load_shouldDeliverNil_onColdCacheLoad_remoteLoadFailure() {
        
        let (load, _, spy) = composeEphemeralLoaders()
        
        assert(load: load, toDeliver: .none) {
            
            spy.complete(with: anyError())
        }
    }
    
    func test_load_shouldDeliverRemoteLoad_onColdCacheLoad_remoteLoadSuccessWithEmptyItems() {
        
        let stamped = makeStamped()
        let (load, _, spy) = composeEphemeralLoaders()
        
        assert(load: load, toDeliver: stamped.value) {
            
            spy.complete(with: stamped)
        }
    }
    
    func test_load_shouldDeliverRemoteLoad_onColdCacheLoad_remoteLoadSuccessWithOneItem() {
        
        let stamped = makeStamped(value: makeItem())
        let (load, _, spy) = composeEphemeralLoaders()
        
        assert(load: load, toDeliver: stamped.value) {
            
            spy.complete(with: stamped)
        }
    }
    
    func test_load_shouldDeliverRemoteLoad_onColdCacheLoad_remoteLoadSuccessWithTwoItem() {
        
        let stamped = makeStamped(value: makeItem(), makeItem())
        let (load, _, spy) = composeEphemeralLoaders()
        
        assert(load: load, toDeliver: stamped.value) {
            
            spy.complete(with: stamped)
        }
    }
    
    // MARK: - reload
    
    func test_reload_shouldDeliverNil_onRemoteLoadFailure_coldCache() {
        
        let (_, reload, spy) = composeEphemeralLoaders()
        
        assert(load: reload, toDeliver: .none) {
            
            spy.complete(with: anyError())
        }
    }
    
    func test_reload_shouldDeliverRemoteLoad_remoteLoadSuccessWithEmptyItems_coldCache() {
        
        let stamped = makeStamped()
        let (_, reload, spy) = composeEphemeralLoaders()
        
        assert(load: reload, toDeliver: stamped.value) {
            
            spy.complete(with: stamped)
        }
    }
    
    func test_reload_shouldDeliverRemoteLoad_remoteLoadSuccessWithOneItem_coldCache() {
        
        let stamped = makeStamped(value: makeItem())
        let (_, reload, spy) = composeEphemeralLoaders()
        
        assert(load: reload, toDeliver: stamped.value) {
            
            spy.complete(with: stamped)
        }
    }
    
    func test_reload_shouldDeliverRemoteLoad_remoteLoadSuccessWithTwoItem_coldCache() {
        
        let stamped = makeStamped(value: makeItem(), makeItem())
        let (_, reload, spy) = composeEphemeralLoaders()
        
        assert(load: reload, toDeliver: stamped.value) {
            
            spy.complete(with: stamped)
        }
    }
    
    // MARK: - load after reload
    
    func test_load_shouldDeliverNil_onBothRemoteLoadFailure() {
        
        let (load, reload, spy) = composeEphemeralLoaders()
        
        assert(load: reload, toDeliver: .none) {
            
            spy.complete(with: anyNSError())
        }
        
        assert(load: load, toDeliver: .none) {
            
            spy.complete(with: anyNSError(), at: 1)
        }
    }
    
    func test_load_shouldDeliverValue_onFirstRemoteLoadFailure_secondSuccess() {
        
        let stamped = makeStamped(value: makeItem())
        let (load, reload, spy) = composeEphemeralLoaders()
        
        assert(load: reload, toDeliver: .none) {
            
            spy.complete(with: anyNSError())
        }
        
        assert(load: load, toDeliver: stamped.value) {
            
            spy.complete(with: stamped, at: 1)
        }
    }
    
    func test_load_shouldDeliverValue_onRemoteLoadSuccess() {
        
        let stamped = makeStamped(value: makeItem())
        let (load, reload, spy) = composeEphemeralLoaders()
        
        assert(load: reload, toDeliver: stamped.value) {
            
            spy.complete(with: stamped)
        }
        
        assert(load: load, toDeliver: stamped.value) {}
    }
    
    // MARK: - Helpers
    
    private typealias RemoteLoadSpy = Spy<String?, Stamped, Error>
    private typealias Stamped = SerialComponents.SerialStamped<String, [Item]>
    
    private func composeEphemeralLoaders(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        load: SUT.Load<[Item]?>,
        reload: SUT.Load<[Item]?>,
        spy: RemoteLoadSpy
    ) {
        let (sut, _,_) = makeSUT(file: file, line: line)
        let spy = RemoteLoadSpy()
        
        let (load, reload) = sut.composeEphemeralLoaders(remoteLoad: spy.process)
        
        return (load, reload, spy)
    }
    
    private func makeStamped(
        value: Item...,
        serial: String = anyMessage()
    ) -> Stamped {
        
        return .init(value: value, serial: serial)
    }
    
    private struct Item: Equatable, Codable {
        
        let value: String
    }
    
    private func makeItem(
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(value: value)
    }
    
    private func assert(
        load: @escaping SUT.Load<[Item]?>,
        toDeliver expected: [Item]?,
        timeout: TimeInterval = 1.0,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, expected, "Expected \(String(describing: expected)), but got \(String(describing: $0)) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        wait(timeout: 0.05)
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
