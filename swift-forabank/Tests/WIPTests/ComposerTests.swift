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
    
    typealias LoadCompletion<T> = ([T]?) -> Void
    typealias Load<T> = (@escaping LoadCompletion<T>) -> Void
    
    func compose<T, Model: Decodable>(
        fromModel: @escaping ([Model]) -> [T]
    ) -> Load<T> {
        
        return {
            
#warning("wrap in scheduler")
            self.agentLoad(fromModel: fromModel, completion: $0)
        }
    }
}

private extension BlaComposer {
    
    func agentLoad<T, Model: Decodable>(
        fromModel: @escaping ([Model]) -> [T],
        completion: @escaping LoadCompletion<T>
    ) {
        guard self.agent.serial(for: Model.self) != nil
        else { return completion(nil) }
        
        let models = self.agent.load(type: [Model].self)
        completion(models.map(fromModel))
    }
}

import XCTest

final class ComposerTests: XCTestCase {
    
    func test_compose_shouldNotCallCollaborators() {
        
        let (sut, agent) = makeSUT()
        
        XCTAssertEqual(agent.loadCallCount, 0)
        XCTAssertEqual(agent.storeCallCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - local load
    
    func test_localLoad_shouldDeliverFailureOnMissingAgentData() {
        
        let (sut, _) = makeSUT(load: nil, serial: anyMessage())
        
        expect(composeLocal(sut).load, toDeliver: nil)
    }
    
    func test_localLoad_shouldDeliverFailureOnAgentEmptyDataMissingSerial() {
        
        let (sut, _) = makeSUT(load: [], serial: nil)
        
        expect(composeLocal(sut).load, toDeliver: nil)
    }
    
    func test_localLoad_shouldDeliverFailureOnMissingAgentSerial() {
        
        let (sut, _) = makeSUT(load: [makeModel()], serial: nil)
        
        expect(composeLocal(sut).load, toDeliver: nil)
    }
    
    func test_localLoad_shouldDeliverFailureOnBothAgentDataAndSerialMissing() {
        
        let (sut, _) = makeSUT(load: nil, serial: nil)
        
        expect(composeLocal(sut).load, toDeliver: nil)
    }
    
    func test_localLoad_shouldCallFromModelWithEmptyOnEmptyLoad() {
        
        let (sut, _) = makeSUT(load: [], serial: anyMessage())
        let (load, fromModelSpy) = composeLocal(sut)
        
        load { _ in }
        
        XCTAssertNoDiff(fromModelSpy.payloads, [[]])
    }
    
    func test_localLoad_shouldCallFromModelWithOneOnAgentLoadOne() {
        
        let model = makeModel()
        let (sut, _) = makeSUT(load: [model], serial: anyMessage())
        let (load, fromModelSpy) = composeLocal(sut)
        
        load { _ in }
        
        XCTAssertNoDiff(fromModelSpy.payloads, [[model]])
    }
    
    func test_localLoad_shouldCallFromModelWithTwoOnAgentLoadTwo() {
        
        let (model1, model2) = (makeModel(), makeModel())
        let (sut, _) = makeSUT(load: [model1, model2], serial: anyMessage())
        let (load, fromModelSpy) = composeLocal(sut)
        
        load { _ in }
        
        XCTAssertNoDiff(fromModelSpy.payloads, [[model1, model2]])
    }
    
    func test_localLoad_shouldDeliverEmptyOnFromModelEmptyAgentEmptyDataAndSerial() {
        
        let (sut, _) = makeSUT(load: [], serial: anyMessage())
        
        expect(composeLocal(sut).load, toDeliver: [])
    }
    
    func test_localLoad_shouldDeliverEmptyOnFromModelEmptyAgentDataAndSerial() {
        
        let (sut, _) = makeSUT(load: [makeModel()], serial: anyMessage())
        
        expect(composeLocal(sut).load, toDeliver: [])
    }
    
    func test_localLoad_shouldDeliverFromModelValueOnBothAgentDataAndSerial() {
        
        let value = makeValue()
        let (sut, _) = makeSUT(load: [makeModel()], serial: anyMessage())
        let (load, _) = composeLocal(sut, with: [value])
        
        expect(load, toDeliver: [value])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BlaComposer
    private typealias Load = SUT.Load<Value?>
    private typealias LocalAgent = LocalAgentSpy<[Model]>
    private typealias FromModelSpy = CallSpy<[Model], [Value]>
    
    private func makeSUT(
        load loadStub: [Model]? = nil,
        store storeStub: Result<Void, Error> = .success(()),
        serial serialStub: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        agent: LocalAgent
    ) {
        let agent = LocalAgent(
            loadStub: loadStub,
            storeStub: storeStub,
            serialStub: serialStub
        )
        let sut = SUT(agent: agent)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(agent, file: file, line: line)
        
        return (sut, agent)
    }
    
    private func composeLocal(
        _ sut: SUT,
        with response: [Value] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (load: Load, spy: FromModelSpy) {
        
        let fromModelSpy = FromModelSpy(response: response)
        let load = sut.compose(fromModel: fromModelSpy.call(payload:))
    
        trackForMemoryLeaks(fromModelSpy, file: file, line: line)
        
        return (load, fromModelSpy)
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
        _ sut: SUT.Load<T>,
        toDeliver expected: [T]?,
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
