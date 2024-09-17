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
        fromLocal: @escaping ([LocalModel]) -> [T]
    ) -> Load<T> {
        
        return {
            
#warning("wrap in scheduler")
            self.agentLoad(fromLocal: fromLocal, completion: $0)
        }
    }
    
#warning("need overload with Payload: WithSerial")
    typealias Serial = String
    typealias RemoteLoadCompletion<T> = (SerialStamped<Serial, T>?) -> Void
    typealias RemoteLoad<T> = (Serial?, @escaping RemoteLoadCompletion<T>) -> Void
    
    func compose<T, LocalModel: Codable, RemoteModel>(
        remote: @escaping RemoteLoad<RemoteModel>,
        fromLocal: @escaping ([LocalModel]) -> [T],
        fromRemote: @escaping ([RemoteModel]) -> [T],
        toLocal: @escaping ([RemoteModel]) -> ([LocalModel])
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
                    completion(models.map(fromLocal))
                    
                case let .some(stamped):
                    completion(fromRemote(stamped.list))
                    try? self.agent.store(toLocal(stamped.list), serial: stamped.serial)
                }
            }
        }
    }
}

private extension BlaComposer {
    
    func agentLoad<T, LocalModel: Decodable>(
        fromLocal: @escaping ([LocalModel]) -> [T],
        completion: @escaping LoadCompletion<T>
    ) {
        guard self.agent.serial(for: [LocalModel].self) != nil
        else { return completion(nil) }
        
        let models = self.agent.load(type: [LocalModel].self)
        completion(models.map(fromLocal))
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
        
        expect(composeLocal(sut).composed, toDeliver: nil)
    }
    
    func test_localLoad_shouldDeliverFailureOnAgentEmptyDataMissingSerial() {
        
        let (sut, _) = makeSUT(load: [], serial: nil)
        
        expect(composeLocal(sut).composed, toDeliver: nil)
    }
    
    func test_localLoad_shouldDeliverFailureOnMissingAgentSerial() {
        
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: nil)
        
        expect(composeLocal(sut).composed, toDeliver: nil)
    }
    
    func test_localLoad_shouldDeliverFailureOnBothAgentDataAndSerialMissing() {
        
        let (sut, _) = makeSUT(load: nil, serial: nil)
        
        expect(composeLocal(sut).composed, toDeliver: nil)
    }
    
    func test_localLoad_shouldCallFromModelWithEmptyOnEmptyLoad() {
        
        let (sut, _) = makeSUT(load: [], serial: anyMessage())
        let (load, fromLocal) = composeLocal(sut)
        
        load { _ in }
        
        XCTAssertNoDiff(fromLocal.payloads, [[]])
    }
    
    func test_localLoad_shouldCallFromModelWithOneOnAgentLoadOne() {
        
        let model = makeLocalModel()
        let (sut, _) = makeSUT(load: [model], serial: anyMessage())
        let (load, fromLocal) = composeLocal(sut)
        
        load { _ in }
        
        XCTAssertNoDiff(fromLocal.payloads, [[model]])
    }
    
    func test_localLoad_shouldCallFromModelWithTwoOnAgentLoadTwo() {
        
        let (model1, model2) = (makeLocalModel(), makeLocalModel())
        let (sut, _) = makeSUT(load: [model1, model2], serial: anyMessage())
        let (load, fromLocal) = composeLocal(sut)
        
        load { _ in }
        
        XCTAssertNoDiff(fromLocal.payloads, [[model1, model2]])
    }
    
    func test_localLoad_shouldDeliverEmptyOnFromModelEmptyAgentEmptyDataAndSerial() {
        
        let (sut, _) = makeSUT(load: [], serial: anyMessage())
        
        expect(composeLocal(sut).composed, toDeliver: [])
    }
    
    func test_localLoad_shouldDeliverEmptyOnFromModelEmptyAgentDataAndSerial() {
        
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: anyMessage())
        
        expect(composeLocal(sut).composed, toDeliver: [])
    }
    
    func test_localLoad_shouldDeliverFromModelValueOnBothAgentDataAndSerial() {
        
        let value = makeValue()
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: anyMessage())
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
        
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: nil)
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
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: serial)
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
        
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: nil)
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
        
        let value = makeValue()
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut, fromLocal: [value])
        
        expect(remoteLoad, toDeliver: [value]) {
            
            remote.complete(with: .none)
        }
    }
    
    func test_remoteLoad_shouldDeliverTwoOnRemoteFailureAgentLoadTwo() {
        
        let (value1, value2) = (makeValue(), makeValue())
        let (sut, _) = makeSUT(load: [makeLocalModel(), makeLocalModel()], serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut, fromLocal: [value1, value2])
        
        expect(remoteLoad, toDeliver: [value1, value2]) {
            
            remote.complete(with: .none)
        }
    }
    
    func test_remoteLoad_shouldCallFromRemoteWithOneOnRemoteLoadOne() {
        
        let remoteModel = makeRemoteModel()
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: anyMessage())
        let (remoteLoad, remote, _, fromRemote) = composeRemote(sut)
        
        remoteLoad { _ in
            
            XCTAssertNoDiff(fromRemote.payloads, [[remoteModel]])
        }
        
        remote.complete(with: .init(list: [remoteModel], serial: anyMessage()))
    }
    
    func test_remoteLoad_shouldDeliverOneOnFromRemoteOne() {
        
        let value = makeValue()
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut, fromRemote: [value])
        
        expect(remoteLoad, toDeliver: [value]) {
            
            remote.complete(with: .init(list: [], serial: anyMessage()))
        }
    }
    
    func test_remoteLoad_shouldCallFromRemoteWithTwoOnRemoteLoadTwo() {
        
        let (remoteModel1, remoteModel2) = (makeRemoteModel(), makeRemoteModel())
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: anyMessage())
        let (remoteLoad, remote, _, fromRemote) = composeRemote(sut)
        
        remoteLoad { _ in
            
            XCTAssertNoDiff(fromRemote.payloads, [[remoteModel1, remoteModel2]])
        }
        
        remote.complete(with: .init(list: [remoteModel1, remoteModel2], serial: anyMessage()))
    }
    
    func test_remoteLoad_shouldDeliverTwoOnFromRemoteTwo() {
        
        let (value1, value2) = (makeValue(), makeValue())
        let (sut, _) = makeSUT(load: [makeLocalModel()], serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut, fromRemote: [value1, value2])
        
        expect(remoteLoad, toDeliver: [value1, value2]) {
            
            remote.complete(with: .init(list: [], serial: anyMessage()))
        }
    }
    
    // MARK: - cache remote load
    
    func test_cacheRemoteLoad_shouldNotCacheOnRemoteFailure() {
        
        let (sut, agent) = makeSUT(load: nil, serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        let remoteExp = expectation(description: "wait for remote completion")
        
        remoteLoad { _ in remoteExp.fulfill() }
        
        remote.complete(with: nil)
        wait(for: [remoteExp], timeout: 1)
        
        XCTAssert(agent.storeMessages.isEmpty)
    }
    
    func test_cacheRemoteLoad_shouldCacheEmptyOnRemoteEmptyLoad() {
        
        let serial = anyMessage()
        let (sut, agent) = makeSUT(load: nil, serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut)
        let remoteExp = expectation(description: "wait for remote completion")
        
        remoteLoad { _ in remoteExp.fulfill() }
        
        remote.complete(with: .init(list: [], serial: serial))
        wait(for: [remoteExp], timeout: 1)
        
        XCTAssertNoDiff(agent.storeMessages.map(\.0), [[]])
        XCTAssertNoDiff(agent.storeMessages.map(\.1), [serial])
    }
    
    func test_cacheRemoteLoad_shouldCacheOneOnToLocalOne() {
        
        let (local, serial) = (makeLocalModel(), anyMessage())
        let (sut, agent) = makeSUT(load: nil, serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut, toLocal: [local])
        let remoteExp = expectation(description: "wait for remote completion")
        
        remoteLoad { _ in remoteExp.fulfill() }
        
        remote.complete(with: .init(list: [], serial: serial))
        wait(for: [remoteExp], timeout: 1)
        
        XCTAssertNoDiff(agent.storeMessages.map(\.0), [[local]])
        XCTAssertNoDiff(agent.storeMessages.map(\.1), [serial])
    }
    
    func test_cacheRemoteLoad_shouldCacheTwoOnToLocalTwo() {
        
        let (local1, local2, serial) = (makeLocalModel(), makeLocalModel(), anyMessage())
        let (sut, agent) = makeSUT(load: nil, serial: anyMessage())
        let (remoteLoad, remote, _,_) = composeRemote(sut, toLocal: [local1, local2])
        let remoteExp = expectation(description: "wait for remote completion")
        
        remoteLoad { _ in remoteExp.fulfill() }
        
        remote.complete(with: .init(list: [], serial: serial))
        wait(for: [remoteExp], timeout: 1)
        
        XCTAssertNoDiff(agent.storeMessages.map(\.0), [[local1, local2]])
        XCTAssertNoDiff(agent.storeMessages.map(\.1), [serial])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = BlaComposer
    private typealias Load = SUT.Load<Value?>
    private typealias LocalAgent = LocalAgentSpy<[LocalModel]>
    private typealias FromLocalSpy = CallSpy<[LocalModel], [Value]>
    private typealias FromRemoteSpy = CallSpy<[RemoteModel], [Value]>
    private typealias ToLocalSpy = CallSpy<[RemoteModel], [LocalModel]>
#warning("need overload for Payload: WithSerial")
    private typealias RemoteLoadSpy = Spy<SUT.Serial?, SerialStamped<SUT.Serial, RemoteModel>?>
    
    private func makeSUT(
        load loadStub: [LocalModel]? = nil,
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
    ) -> (composed: Load, fromLocal: FromLocalSpy) {
        
        let fromLocal = FromLocalSpy(response: response)
        let composed = sut.compose(fromLocal: fromLocal.call(payload:))
        
        trackForMemoryLeaks(fromLocal, file: file, line: line)
        
        return (composed, fromLocal)
    }
    
    private func composeRemote(
        _ sut: SUT,
        fromLocal: [Value] = [],
        fromRemote: [Value] = [],
        toLocal: [LocalModel] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (composed: Load, remote: RemoteLoadSpy, fromLocal: FromLocalSpy, fromRemote: FromRemoteSpy) {
        
        let remote = RemoteLoadSpy()
        let fromLocal = FromLocalSpy(response: fromLocal)
        let fromRemote = FromRemoteSpy(response: fromRemote)
        let toLocal = ToLocalSpy(response: toLocal)
        let composed = sut.compose(
            remote: remote.process(_:completion:),
            fromLocal: fromLocal.call(payload:),
            fromRemote: fromRemote.call(payload:),
            toLocal: toLocal.call(payload:)
        )
        
        trackForMemoryLeaks(remote, file: file, line: line)
        trackForMemoryLeaks(fromLocal, file: file, line: line)
        trackForMemoryLeaks(fromRemote, file: file, line: line)
        
        return (composed, remote, fromLocal, fromRemote)
    }
    
    private struct LocalModel: Codable, Equatable {
        
        let value: String
    }
    
    private func makeLocalModel(
        _ value: String = anyMessage()
    ) -> LocalModel {
        
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
