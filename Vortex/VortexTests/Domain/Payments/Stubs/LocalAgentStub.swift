//
//  LocalAgentStub.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.02.2023.
//

@testable import ForaBank
import Foundation

final class LocalAgentStub: LocalAgentProtocol {
    
    private let stub: [String: Data]
    
    init(stub: [String: Data]) {
        self.stub = stub
    }
    
    func load<T: Decodable>(type: T.Type) -> T? {
        
        do {
            guard let data = stub["\(type.self)"] else {
                throw MCError("LocalAgentStub: No stub for \(type.self).")
            }
            
            return try JSONDecoder().decode(T.self, from: data)
            
        } catch {
            return nil
        }
    }
    
    // MARK: - Unimplemented
    
    func store<T: Encodable>(_ data: T, serial: String?) throws {
        throw MCError("LocalAgentStub.store unimplemented.")
    }
    
    func clear<T>(type: T.Type) throws {
        throw MCError("LocalAgentStub.clear unimplemented.")
    }
    
    func serial<T>(for type: T.Type) -> String? {
        nil
    }
}
