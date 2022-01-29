//
//  LocalAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 20.01.2022.
//

import Foundation

protocol LocalAgentProtocol {
    
    //TODO: implement storing and loading single item
    func store<T>(_ data: [T], serial: Int?) throws where T: Cachable
    func load<T>(type: T.Type) -> [T]? where T : Cachable
    func clear<T>(type: T.Type) throws where T: Cachable
    func serial<T>(for type: T.Type) -> Int? where T : Cachable
    func fileName<T>(for type: T.Type) -> String
}

extension LocalAgentProtocol {
    
    func fileName<T>(for type: T.Type) -> String {
        
        "\(type.self)s.json".lowercased()
    }
}
