//
//  ComposerTests.swift
//
//
//  Created by Igor Malyarov on 17.09.2024.
//

final class BlaComposer {
    
    private let agent: any LocalAgentProtocol
    
    init(agent: any LocalAgentProtocol) {
        
        self.agent = agent
    }
}

extension BlaComposer {
    
    typealias LoadCompletion<T> = (T) -> Void
    typealias Load<T> = (@escaping LoadCompletion<T>) -> Void
    
    func compose<T, Model: Decodable>(
        fromModel: @escaping (Model) -> T
    ) -> Load<T?> {
        
        return {
            
#warning("wrap in scheduler")
            self.agentLoad(fromModel: fromModel, completion: $0)
        }
    }
}

private extension BlaComposer {
    
    func agentLoad<T, Model: Decodable>(
        fromModel: @escaping (Model) -> T,
        completion: @escaping LoadCompletion<T?>
    ) {
        guard self.agent.serial(for: Model.self) != nil
        else { return completion(nil) }
        
        let model = self.agent.load(type: Model.self)
        completion(model.map(fromModel))
    }
}

import XCTest

final class ComposerTests: XCTestCase {
    
    func test_compose_shouldNotCallCollaborators() {
        
        let (sut, agent, fromModel) = makeSUT()
        
        XCTAssertEqual(agent.loadCallCount, 0)
        XCTAssertEqual(agent.storeCallCount, 0)
        XCTAssertEqual(fromModel.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - local load
    
    func test_localLoad_shouldDeliverFailureOnAgentDataFailure() {
        
        let (sut, _,_) = makeSUT(load: nil, serial: anyMessage())
        
        expect(sut, toDeliver: nil)
    }
    
    func test_localLoad_shouldDeliverFailureOnAgentSerialFailure() {
        
        let (sut, _,_) = makeSUT(load: makeModel(), serial: nil)
        
        expect(sut, toDeliver: nil)
    }
    
    func test_localLoad_shouldDeliverFailureOnBothAgentDataAndSerialFailures() {
        
        let (sut, _,_) = makeSUT(load: nil, serial: nil)
        
        expect(sut, toDeliver: nil)
    }
    
    func test_localLoad_shouldCallFromModelWithAgentLoad() {
        
        let model = makeModel()
        let (sut, _, fromModel) = makeSUT(load: model, serial: anyMessage(), fromModel: makeValue())
        
        sut { _ in }
        
        XCTAssertNoDiff(fromModel.payloads, [model])
    }
    
    func test_localLoad_shouldDeliverValueOnBothAgentDataAndSerial() {
        
        let value = makeValue()
        let (sut, _,_) = makeSUT(load: makeModel(), serial: anyMessage(), fromModel: value)
        
        expect(sut, toDeliver: value)
    }
    
    // MARK: - Helpers
    
    private typealias Composer = BlaComposer
    private typealias SUT = Composer.Load<Value?>
    private typealias LocalAgent = LocalAgentSpy<Model>
    private typealias FromModelSpy = CallSpy<Model, Value>
    
    private func makeSUT(
        load loadStub: Model? = nil,
        store storeStub: Result<Void, Error> = .success(()),
        serial serialStub: String? = nil,
        fromModel value: Value? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        agent: LocalAgent,
        fromModelSpy: FromModelSpy
    ) {
        let agent = LocalAgent(
            loadStub: loadStub,
            storeStub: storeStub,
            serialStub: serialStub
        )
        let composer = Composer(agent: agent)
        let fromModelSpy = FromModelSpy(response: value ?? makeValue())
        let sut: SUT = composer.compose(fromModel: fromModelSpy.call(payload:))
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(agent, file: file, line: line)
        trackForMemoryLeaks(fromModelSpy, file: file, line: line)
        
        return (sut, agent, fromModelSpy)
    }
    
    private struct Model: Decodable, Equatable {
        
        let value: String
    }
    
    private func makeModel(
        _ value: String = anyMessage()
    ) -> Model {
        
        return .init(value: value)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private func expect<T: Equatable>(
        _ sut: Composer.Load<T?>,
        toDeliver expected: T?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut {
            
            XCTAssertNoDiff($0, expected, "Expected \(String(describing: expected)), got \(String(describing: $0)) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
