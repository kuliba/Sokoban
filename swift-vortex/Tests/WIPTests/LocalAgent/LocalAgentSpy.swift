//
//  LocalAgentSpy.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.09.2024.
//

import Foundation

final class LocalAgentSpy<Value>: LocalAgentProtocol {
    
    private(set) var storeCallCount = 0
    private(set) var loadCallCount = 0
    private(set) var storeMessages = [(Value, String?)]()
    private var loadStub: Value?
    private var storeStub: Result<Void, Error>
    private var serialStub: String?
    
    init(
        loadStub: Value? = nil,
        storeStub: Result<Void, Error> = .success(()),
        serialStub: String? = nil
    ) {
        self.loadStub = loadStub
        self.storeStub = storeStub
        self.serialStub = serialStub
    }
    
    func store<T>(
        _ data: T,
        serial: String?
    ) throws where T : Encodable {
        
        storeCallCount += 1
        
        if let data = data as? Value {
            storeMessages.append((data, serial))
        } else {
            throw NSError(domain: "Unknown type", code: -1)
        }
        
        try storeStub.get()
    }
    
    func load<T>(type: T.Type) -> T? where T : Decodable {
        
        loadCallCount += 1
        
        return loadStub as? T
    }
    
    func clear<T>(type: T.Type) throws {}
    
    func serial<T>(for type: T.Type) -> String? {
        
        return serialStub
    }
}
