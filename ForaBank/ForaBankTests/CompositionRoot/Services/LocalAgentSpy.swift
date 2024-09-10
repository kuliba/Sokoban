//
//  LocalAgentSpy.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.09.2024.
//

@testable import ForaBank
import Foundation

final class LocalAgentSpy<Value>: LocalAgentProtocol {
    
    private(set) var storeMessages = [(Value, String?)]()
    private var loadStub: Value?
    private var serialStub: String?
    
    init(
        loadStub: Value? = nil,
        serialStub: String? = nil
    ) {
        self.loadStub = loadStub
        self.serialStub = serialStub
    }
    
    func store<T>(
        _ data: T,
        serial: String?
    ) throws where T : Encodable {
        
        if let data = data as? Value {
            storeMessages.append((data, serial))
        } else {
            throw NSError(domain: "Unknown type", code: -1)
        }
    }
    
    func load<T>(type: T.Type) -> T? where T : Decodable {
        
        loadStub as? T
    }
    
    func clear<T>(type: T.Type) throws {
        
    }
    
    func serial<T>(for type: T.Type) -> String? {
        
        serialStub
    }
}
