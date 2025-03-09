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
    
    func test_shouldDeliverNil_onColdCacheLoad_remoteLoadFailure() {
        
        let (load, _, spy) = composeEphemeralLoaders()
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, .none)
            exp.fulfill()
        }
        
        wait(timeout: 0.05)
        spy.complete(with: anyError())
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverRemoteLoad_onColdCacheLoad_remoteLoadSuccessWithEmptyItems() {
        
        let stamped = makeStamped()
        let (load, _, spy) = composeEphemeralLoaders()
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, stamped.value)
            exp.fulfill()
        }
        
        wait(timeout: 0.05)
        spy.complete(with: stamped)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverRemoteLoad_onColdCacheLoad_remoteLoadSuccessWithOneItem() {
        
        let stamped = makeStamped(value: makeItem())
        let (load, _, spy) = composeEphemeralLoaders()
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, stamped.value)
            exp.fulfill()
        }
        
        wait(timeout: 0.05)
        spy.complete(with: stamped)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverRemoteLoad_onColdCacheLoad_remoteLoadSuccessWithTwoItem() {
        
        let stamped = makeStamped(value: makeItem(), makeItem())
        let (load, _, spy) = composeEphemeralLoaders()
        let exp = expectation(description: "wait for load completion")
        
        load {
            
            XCTAssertNoDiff($0, stamped.value)
            exp.fulfill()
        }
        
        wait(timeout: 0.05)
        spy.complete(with: stamped)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias RemoteLoadSpy = Spy<String?, Stamped, Error>
    private typealias Stamped = SerialComponents.SerialStamped<String, [Item]>
    
    private func composeEphemeralLoaders(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        load: SUT.Load<[Item]>,
        reload: SUT.Load<[Item]>,
        spy: RemoteLoadSpy
    ) {
        let (sut, _,_) = makeSUT(file: file, line: line)
        let spy = RemoteLoadSpy()
        
        let (load, reload) = sut.composeLoaders(
            localAgent: NullLocalAgent(),
            remoteLoad: spy.process,
            fromModel: { $0 },
            toModel: { $0 }
        )
        
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
}
