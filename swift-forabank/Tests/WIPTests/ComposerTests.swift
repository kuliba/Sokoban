//
//  ComposerTests.swift
//
//
//  Created by Igor Malyarov on 17.09.2024.
//

struct SerialStamped<Serial, T> {
    
    let list: [T]
    let serial: Serial
}

final class BlaComposer {
    
    private let agent: any LocalAgentProtocol
    
    init(agent: any LocalAgentProtocol) {
        
        self.agent = agent
    }
}

extension BlaComposer {
    
    typealias LoadCompletion<T> = ([T]?) -> Void
    typealias Load<T> = (@escaping LoadCompletion<T>) -> Void
    
    func compose<T, LocalModel: Decodable>(
        fromModel: @escaping ([LocalModel]) -> [T]
    ) -> Load<T> {
        
        return {
            
#warning("wrap in scheduler")
            self.agentLoad(fromModel: fromModel, completion: $0)
        }
    }
    
#warning("need overload with Payload: WithSerial")
    typealias Serial = String
    typealias RemoteLoadCompletion<T> = (SerialStamped<Serial, T>?) -> Void
    typealias RemoteLoad<T> = (Serial?, @escaping RemoteLoadCompletion<T>) -> Void
    
    func compose<T, LocalModel: Decodable, RemoteModel>(
        remote: @escaping RemoteLoad<RemoteModel>,
        fromLocalModel: @escaping ([LocalModel]) -> [T],
        fromRemoteModel: @escaping ([RemoteModel]) -> [T]
    ) -> Load<T> {
        
        let serial = self.agent.serial(for: [LocalModel].self)
        let models = self.agent.load(type: [LocalModel].self)
        
        return { completion in
            
            let serial = models == nil ? nil : serial
            let models = serial == nil ? nil : models
            
#warning("wrap in scheduler")
            remote(serial) {
           
                switch $0 {
                case .none:
                    completion(models.map(fromLocalModel))
                    
                case let .some(stamped):
                    completion(nil)
                }
            }
        }
    }
}

private extension BlaComposer {
    
    func agentLoad<T, LocalModel: Decodable>(
        fromModel: @escaping ([LocalModel]) -> [T],
        completion: @escaping LoadCompletion<T>
    ) {
        guard self.agent.serial(for: [LocalModel].self) != nil
        else { return completion(nil) }
        
        let models = self.agent.load(type: [LocalModel].self)
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
    
    // MARK: - remote load
    
    func test_remoteLoad_shouldCallRemoteWithoutSerialOnMissingAgentData() {
        
        let (sut, _) = makeSUT(load: nil, serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        remoteLoad { _ in }
        
        XCTAssertNoDiff(remote.payloads, [nil])
    }
    
    func test_remoteLoad_shouldCallRemoteWithoutSerialOnAgentEmptyDataMissingSerial() {
        
        let (sut, _) = makeSUT(load: [], serial: nil)
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        remoteLoad { _ in }
        
        XCTAssertNoDiff(remote.payloads, [nil])
    }
    
    func test_remoteLoad_shouldCallRemoteWithoutSerialOnMissingAgentSerial() {
        
        let (sut, _) = makeSUT(load: [makeModel()], serial: nil)
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        remoteLoad { _ in }
        
        XCTAssertNoDiff(remote.payloads, [nil])
    }
    
    func test_remoteLoad_shouldCallRemoteWithoutSerialOnBothAgentDataAndSerialMissing() {
        
        let (sut, _) = makeSUT(load: nil, serial: nil)
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        remoteLoad { _ in }
        
        XCTAssertNoDiff(remote.payloads, [nil])
    }
    
    func test_remoteLoad_shouldCallRemoteWitSerialOnEmptyAgentDataAndSerial() {
        
        let serial = anyMessage()
        let (sut, _) = makeSUT(load: [], serial: serial)
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        remoteLoad { _ in }
        
        XCTAssertNoDiff(remote.payloads, [serial])
    }
    
    func test_remoteLoad_shouldCallRemoteWitSerialOnNonEmptyAgentDataAndSerial() {
        
        let serial = anyMessage()
        let (sut, _) = makeSUT(load: [makeModel()], serial: serial)
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        remoteLoad { _ in }
        
        XCTAssertNoDiff(remote.payloads, [serial])
    }
    
    func test_remoteLoad_shouldDeliverFailureOnRemoteFailureMissingAgentData() {
        
        let (sut, _) = makeSUT(load: nil, serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        expect(remoteLoad, toDeliver: nil) {
            
            remote.complete(with: .none)
        }
    }
    
    func test_remoteLoad_shouldDeliverFailureOnRemoteFailureAgentEmptyDataMissingSerial() {
        
        let (sut, _) = makeSUT(load: [], serial: nil)
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        expect(remoteLoad, toDeliver: nil) {
            
            remote.complete(with: .none)
        }
    }
    
    func test_remoteLoad_shouldDeliverFailureOnRemoteFailureMissingAgentSerial() {
        
        let (sut, _) = makeSUT(load: [makeModel()], serial: nil)
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        expect(remoteLoad, toDeliver: nil) {
            
            remote.complete(with: .none)
        }
    }
    
    func test_remoteLoad_shouldDeliverFailureOnRemoteFailureBothAgentDataAndSerialMissing() {
        
        let (sut, _) = makeSUT(load: nil, serial: nil)
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        expect(remoteLoad, toDeliver: nil) {
            
            remote.complete(with: .none)
        }
    }
    
    func test_remoteLoad_shouldDeliverEmptyOnRemoteFailureEmptyAgentEmptyDataAndSerial() {
        
        let (sut, _) = makeSUT(load: [], serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        
        expect(remoteLoad, toDeliver: []) {
            
            remote.complete(with: .none)
        }
    }
    
    func test_remoteLoad_shouldDeliverOneOnRemoteFailureAgentLoadOne() {
        
        let (model, value) = (makeModel(), makeValue())
        let (sut, _) = makeSUT(load: [model], serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut, fromLocal: [value])
        
        expect(remoteLoad, toDeliver: [value]) {
            
            remote.complete(with: .none)
        }
    }
    
    func test_remoteLoad_shouldDeliverTwoOnRemoteFailureAgentLoadTwo() {
        
        let (model1, value1) = (makeModel(), makeValue())
        let (model2, value2) = (makeModel(), makeValue())
        let (sut, _) = makeSUT(load: [model1, model2], serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut, fromLocal: [value1, value2])
        
        expect(remoteLoad, toDeliver: [value1, value2]) {
            
            remote.complete(with: .none)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BlaComposer
    private typealias Load = SUT.Load<Value?>
    private typealias LocalAgent = LocalAgentSpy<[Model]>
    private typealias FromLocalModelSpy = CallSpy<[Model], [Value]>
    private typealias FromRemoteModelSpy = CallSpy<[RemoteModel], [Value]>
#warning("need overload for Payload: WithSerial")
    private typealias RemoteLoadSpy = Spy<SUT.Serial?, SerialStamped<SUT.Serial, RemoteModel>?>
    
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
    ) -> (load: Load, spy: FromLocalModelSpy) {
        
        let spy = FromLocalModelSpy(response: response)
        let load = sut.compose(fromModel: spy.call(payload:))
        
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (load, spy)
    }
    
    private func composeRemote(
        _ sut: SUT,
        fromLocal: [Value] = [],
        fromRemote: [Value] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (load: Load, remote: RemoteLoadSpy, fromLocalModel: FromLocalModelSpy, fromRemoteModel: FromRemoteModelSpy) {
        
        let remote = RemoteLoadSpy()
        let fromLocalModel = FromLocalModelSpy(response: fromLocal)
        let fromRemoteModel = FromRemoteModelSpy(response: fromRemote)
        let load = sut.compose(
            remote: remote.process(_:completion:),
            fromLocalModel: fromLocalModel.call(payload:),
            fromRemoteModel: fromRemoteModel.call(payload:)
        )
        
        trackForMemoryLeaks(remote, file: file, line: line)
        trackForMemoryLeaks(fromLocalModel, file: file, line: line)
        trackForMemoryLeaks(fromRemoteModel, file: file, line: line)
        
        return (load, remote, fromLocalModel, fromRemoteModel)
    }
    
    private struct Model: Decodable, Equatable {
        
        let value: String
    }
    
    private func makeModel(
        _ value: String = anyMessage()
    ) -> Model {
        
        return .init(value: value)
    }
    
    private struct RemoteModel: Decodable, Equatable {
        
        let value: String
    }
    
    private func makeRemoteModel(
        _ value: String = anyMessage()
    ) -> RemoteModel {
        
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
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut {
            
            XCTAssertNoDiff($0, expected, "Expected \(String(describing: expected)), got \(String(describing: $0)) instead.", file: file, line: line)
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
