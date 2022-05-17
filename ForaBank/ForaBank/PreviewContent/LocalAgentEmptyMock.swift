//
//  LocalAgentEmptyMock.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation

class LocalAgentEmptyMock: LocalAgentProtocol {
    
    func store<T>(_ data: T, serial: String?) throws where T : Encodable {}
    
    func load<T>(type: T.Type) -> T? where T : Decodable { return nil }
    
    func clear<T>(type: T.Type) throws {}
    
    func serial<T>(for type: T.Type) -> String? { return nil }
}
