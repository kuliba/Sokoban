//
//  EphemeralCacheTests.swift
//
//
//  Created by Igor Malyarov on 06.03.2025.
//

import EphemeralCache
import XCTest

final class EphemeralCacheTests: XCTestCase {
    
    func test_objectForKey_shouldReturnCachedValue_onExistingValue() {
        
        let key = anyMessage()
        let (sut, model) = makeSUT()
        
        sut.cache(model, forKey: key)
        let cachedModel = sut.object(forKey: key)
        
        XCTAssertNotNil(cachedModel)
        XCTAssertTrue(cachedModel === model)
    }
    
    func test_objectForKey_shouldReturnNilAndRemoveStaleEntry_onDeallocatedValue() {
        
        let key = anyMessage()
        let (sut, _) = makeSUT()
        weak var weakModel: Model?
        
        autoreleasepool {
            
            let model = makeModel(value: 1)
            sut.cache(model, forKey: key)
            weakModel = model
        }
        
        XCTAssertNil(weakModel)
        
        let cachedModel = sut.object(forKey: key)
        XCTAssertNil(cachedModel)
    }
    
    func test_cache_shouldStoreValueCorrectly_onCachingModel() {
        
        let key = anyMessage()
        let (sut, model) = makeSUT()
        
        sut.cache(model, forKey: key)
        let cachedModel = sut.object(forKey: key)
        XCTAssertNotNil(cachedModel)
        XCTAssertTrue(cachedModel === model)
    }
    
    func test_cache_shouldOverrideExistingValue_onReCachingModel() {
        
        let key = anyMessage()
        let (sut, model1) = makeSUT()
        
        sut.cache(model1, forKey: key)
        let model2 = Model(value: 2)
        
        sut.cache(model2, forKey: key)
        let cachedModel = sut.object(forKey: key)
        
        XCTAssertNotNil(cachedModel)
        XCTAssertTrue(cachedModel === model2)
    }
    
    func test_cleanup_shouldRemoveAllStaleEntries_onInvocation() {
        
        let key = anyMessage()
        let (sut, _) = makeSUT()
        
        autoreleasepool {
            
            let model = makeModel(value: 1)
            sut.cache(model, forKey: key)
        }
        let model2 = Model(value: 2)
        sut.cache(model2, forKey: "key2")
        sut.cleanup()
        
        XCTAssertNil(sut.object(forKey: key))
        XCTAssertNotNil(sut.object(forKey: "key2"))
    }
    
    func test_cleanup_shouldNotRemoveValidEntries_onActiveCache() {
        
        let key = anyMessage()
        let (sut, model) = makeSUT()
        
        sut.cache(model, forKey: key)
        sut.cleanup()
        
        XCTAssertNotNil(sut.object(forKey: key))
    }
    
    func test_subscriptGetter_shouldReturnCachedValue_onValidKey() {
        
        let key = anyMessage()
        let (sut, model) = makeSUT()
        
        sut.cache(model, forKey: key)
        let cachedModel = sut[key]
        
        XCTAssertNotNil(cachedModel)
        XCTAssertTrue(cachedModel === model)
    }
    
    func test_subscriptSetter_shouldStoreValueCorrectly_onValidAssignment() {
        
        let key = anyMessage()
        let (sut, model) = makeSUT()
        
        sut[key] = model
        let cachedModel = sut[key]
        
        XCTAssertNotNil(cachedModel)
        XCTAssertTrue(cachedModel === model)
    }
    
    func test_subscriptSetter_shouldRemoveEntry_onNilAssignment() {
        
        let key = anyMessage()
        let (sut, model) = makeSUT()
        
        sut.cache(model, forKey: key)
        sut[key] = nil
        let cachedModel = sut[key]
        
        XCTAssertNil(cachedModel)
    }
    
    func test_subscript_shouldWorkConsistently_onValueUpdate() {
        
        let key = anyMessage()
        let (sut, model1) = makeSUT()
        
        sut[key] = model1
        
        XCTAssertTrue(sut[key] === model1)
        
        let model2 = Model(value: 2)
        sut[key] = model2
        
        XCTAssertTrue(sut[key] === model2)
    }
    
    func test_threadSafety_shouldMaintainIntegrity_onConcurrentAccess() throws {
        
        let (sut, _) = makeSUT()
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .default)
        
        var models = [Model?](repeating: nil, count: 1000)
        let modelsLock = NSLock()
        
        for i in 0..<1_000 {
            
            group.enter()
            queue.async {
                
                let model = Model(value: i)
                sut.cache(model, forKey: "\(i)")
                modelsLock.lock()
                models[i] = model
                modelsLock.unlock()
                _ = sut.object(forKey: "\(i)")
                group.leave()
            }
        }
        group.wait()
        
        for i in 0..<1_000 {
            
            let model = try XCTUnwrap(sut.object(forKey: "\(i)"))
            XCTAssertEqual(model.value, i)
        }
    }
    
    func test_threadSafety_shouldMaintainIntegrity_onConcurrentReads() throws {
        
        let (sut, _) = makeSUT()
        var strongModels = [Model]()
        
        for i in 0..<1_000 {
            
            let model = makeModel(value: i)
            strongModels.append(model)
            sut.cache(model, forKey: "\(i)")
        }
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .default)
        for _ in 0..<1000 {
            
            group.enter()
            queue.async {
                
                for i in 0..<1_000 {
                    _ = sut.object(forKey: "\(i)")
                }
                group.leave()
            }
        }
        group.wait()
        
        for i in 0..<1_000 {
            
            let model = try XCTUnwrap(sut.object(forKey: "\(i)"))
            XCTAssertEqual(model.value, i)
        }
    }
    
    func test_threadSafety_shouldMaintainIntegrity_onConcurrentWrites() throws {
        
        let (sut, _) = makeSUT()
        var strongModels = [Model]()
        
        for i in 0..<1_000 {
            
            strongModels.append(Model(value: i))
        }
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .default)
        
        for i in 0..<1_000 {
            
            group.enter()
            queue.async {
                
                sut.cache(strongModels[i], forKey: "\(i)")
                group.leave()
            }
        }
        group.wait()
        
        for i in 0..<1_000 {
            
            let model = try XCTUnwrap(sut.object(forKey: "\(i)"))
            XCTAssertEqual(model.value, i)
        }
    }
    
    func test_objectForKey_shouldDeallocateModel_whenNoStrongReferencesExist() {
        
        let key = anyMessage()
        let (sut, _) = makeSUT()
        weak var weakModel: Model?
        
        autoreleasepool {
            
            let model = makeModel(value: 1)
            sut.cache(model, forKey: key)
            weakModel = model
        }
        XCTAssertNil(weakModel)
        XCTAssertNil(sut.object(forKey: key))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = EphemeralCache<String, Model>
    
    private func makeSUT(
        value: Int = .random(in: 0..<100),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        model: Model
    ) {
        let sut = SUT()
        let model = makeModel(value: value)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    private final class Model {
        
        let value: Int
        
        init(value: Int) {
            self.value = value
        }
    }
    
    private func makeModel(
        value: Int = .random(in: 0..<100)
    ) -> Model {
        
        return .init(value: value)
    }
}
