//
//  RemotePriorityReducerTests.swift
//  
//
//  Created by Igor Malyarov on 06.09.2023.
//

import LoadableModel
import XCTest

final class RemotePriorityReducerTests: XCTestCase {
    
    // MARK: - local load failures
    
    func test_reduce_placeholder_loadLocalError() {
        
        let state = reducer.reduce(
            .placeholder,
            .loadLocal(.failure(.localError))
        )
        
        XCTAssertEqual(state, .placeholder)
    }
    
    func test_reduce_localResource_loadLocalError() {
        
        let state = reducer.reduce(
            .local("abc"),
            .loadLocal(.failure(.localError))
        )
        
        XCTAssertEqual(state, .local("abc"))
    }
    
    func test_reduce_remoteResource_loadLocalError() {
        
        let state = reducer.reduce(
            .remote("abc"),
            .loadLocal(.failure(.localError))
        )
        
        XCTAssertEqual(state, .remote("abc"))
    }
    
    func test_reduce_failureLocalError_loadLocalError() {
        
        let state = reducer.reduce(
            .failure(.localError),
            .loadLocal(.failure(.localError))
        )
        
        XCTAssertEqual(state, .failure(.localError))
    }
    
    func test_reduce_failureRemoteError_loadLocalError() {
        
        let state = reducer.reduce(
            .failure(.remoteError),
            .loadLocal(.failure(.localError))
        )
        
        XCTAssertEqual(state, .failure(.remoteError))
    }
    
    func test_reduce_failureLocalErrorWithResource_loadLocalError() {
        
        let state = reducer.reduce(
            .failure2("abc", .localError),
            .loadLocal(.failure(.localError))
        )
        
        XCTAssertEqual(state, .failure2("abc", .localError))
    }
    
    func test_reduce_failureRemoteErrorWithResource_loadLocalError() {
        
        let state = reducer.reduce(
            .failure2("abc", .remoteError),
            .loadLocal(.failure(.localError))
        )
        
        XCTAssertEqual(state, .failure2("abc", .remoteError))
    }
    
    // MARK: - local load success
    
    func test_reduce_placeholder_loadLocalSuccess() {
        
        let state = reducer.reduce(
            .placeholder,
            .loadLocal(.success("123"))
        )
        
        XCTAssertEqual(state, .local("123"))
    }
    
    func test_reduce_localResource_loadLocalSuccess() {
        
        let state = reducer.reduce(
            .local("abc"),
            .loadLocal(.success("123"))
        )
        
        XCTAssertEqual(state, .local("123"))
    }
    
    func test_reduce_remoteResource_loadLocalSuccess() {
        
        let state = reducer.reduce(
            .remote("abc"),
            .loadLocal(.success("123"))
        )
        
        XCTAssertEqual(state, .remote("abc"))
    }
    
    func test_reduce_failureLocalError_loadLocalSuccess() {
        
        let state = reducer.reduce(
            .failure(.localError),
            .loadLocal(.success("123"))
        )
        
        XCTAssertEqual(state, .failure(.localError))
    }
    
    func test_reduce_failureRemoteError_loadLocalSuccess() {
        
        let state = reducer.reduce(
            .failure(.remoteError),
            .loadLocal(.success("123"))
        )
        
        XCTAssertEqual(state, .failure(.remoteError))
    }
    
    func test_reduce_failureLocalErrorWithResource_loadLocalSuccess() {
        
        let state = reducer.reduce(
            .failure2("abc", .localError),
            .loadLocal(.success("123"))
        )
        
        XCTAssertEqual(state, .failure2("abc", .localError))
    }
    
    func test_reduce_failureRemoteErrorWithResource_loadLocalSuccess() {
        
        let state = reducer.reduce(
            .failure2("abc", .remoteError),
            .loadLocal(.success("123"))
        )
        
        XCTAssertEqual(state, .failure2("abc", .remoteError))
    }
    
    // MARK: - remote load failures
    
    func test_reduce_placeholder_loadRemoteError() {
        
        let state = reducer.reduce(
            .placeholder,
            .loadRemote(.failure(.remoteError))
        )
        
        XCTAssertEqual(state, .failure(.remoteError))
    }
    
    func test_reduce_localResource_loadRemoteError() {
        
        let state = reducer.reduce(
            .local("abc"),
            .loadRemote(.failure(.remoteError))
        )
        
        XCTAssertEqual(state, .failure2("abc", .remoteError))
    }
    
    func test_reduce_remoteResource_loadRemoteError() {
        
        let state = reducer.reduce(
            .remote("abc"),
            .loadRemote(.failure(.remoteError))
        )
        
        XCTAssertEqual(state, .failure2("abc", .remoteError))
    }
    
    func test_reduce_failureLocalError_loadRemoteError() {
        
        let state = reducer.reduce(
            .failure(.localError),
            .loadRemote(.failure(.remoteError))
        )
        
        XCTAssertEqual(state, .failure(.remoteError))
    }
    
    func test_reduce_failureRemoteError_loadRemoteError() {
        
        let state = reducer.reduce(
            .failure(.remoteError),
            .loadRemote(.failure(.remoteError))
        )
        
        XCTAssertEqual(state, .failure(.remoteError))
    }
    
    func test_reduce_failureLocalErrorWithResource_loadRemoteError() {
        
        let state = reducer.reduce(
            .failure2("abc", .localError),
            .loadRemote(.failure(.remoteError))
        )
        
        XCTAssertEqual(state, .failure2("abc", .remoteError))
    }
    
    func test_reduce_failureRemoteErrorWithResource_loadRemoteError() {
        
        let state = reducer.reduce(
            .failure2("abc", .remoteError),
            .loadRemote(.failure(.remoteError))
        )
        
        XCTAssertEqual(state, .failure2("abc", .remoteError))
    }
    
    // MARK: - remote load success
    
    func test_reduce_placeholder_loadRemoteSuccess() {
        
        let state = reducer.reduce(
            .placeholder,
            .loadRemote(.success("123"))
        )
        
        XCTAssertEqual(state, .remote("123"))
    }
    
    func test_reduce_localResource_loadRemoteSuccess() {
        
        let state = reducer.reduce(
            .local("abc"),
            .loadRemote(.success("123"))
        )
        
        XCTAssertEqual(state, .remote("123"))
    }
    
    func test_reduce_remoteResource_loadRemoteSuccess() {
        
        let state = reducer.reduce(
            .remote("abc"),
            .loadRemote(.success("123"))
        )
        
        XCTAssertEqual(state, .remote("123"))
    }
    
    func test_reduce_failureLocalError_loadRemoteSuccess() {
        
        let state = reducer.reduce(
            .failure(.localError),
            .loadRemote(.success("123"))
        )
        
        XCTAssertEqual(state, .remote("123"))
    }
    
    func test_reduce_failureRemoteError_loadRemoteSuccess() {
        
        let state = reducer.reduce(
            .failure(.remoteError),
            .loadRemote(.success("123"))
        )
        
        XCTAssertEqual(state, .remote("123"))
    }
    
    func test_reduce_failureLocalErrorWithResource_loadRemoteSuccess() {
        
        let state = reducer.reduce(
            .failure2("abc", .localError),
            .loadRemote(.success("123"))
        )
        
        XCTAssertEqual(state, .remote("123"))
    }
    
    func test_reduce_failureRemoteErrorWithResource_loadRemoteSuccess() {
        
        let state = reducer.reduce(
            .failure2("abc", .remoteError),
            .loadRemote(.success("123"))
        )
        
        XCTAssertEqual(state, .remote("123"))
    }
    
    // MARK: - Helpers
    
    private typealias Model = LoadableModel<String, LoadError>
    private typealias Reducer = Model.Reducer
    
    private let reducer: Model.Reducer = .remotePriority
    
    enum LoadError: Error, Equatable {
        
        case localError
        case remoteError
    }
}
