//
//  LocalAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 20.01.2022.
//

import Foundation

protocol LocalAgentProtocol {
    
    func store<T>(_ data: T, serial: Int?) throws where T : Cachable
    func store<T>(_ data: T, serial: Int?) throws where T : Collection, T : Encodable, T.Element : Cachable
    
    func load<T>(type: T.Type) -> T? where T : Cachable
    func load<T>(type: T.Type) -> T? where T : Collection, T : Decodable, T.Element : Cachable
    
    func clear<T>(type: T.Type) throws where T : Cachable
    func clear<T>(type: T.Type) throws where T : Collection, T.Element : Cachable
    
    func serial<T>(for type: T.Type) -> Int? where T : Cachable
    func serial<T>(for type: T.Type) -> Int? where T : Collection, T.Element : Cachable
    
    func fileName<T>(for type: T.Type) -> String
}

extension LocalAgentProtocol {
    
    func fileName<T>(for type: T.Type) -> String {
        
        "\(type.self).json"
            .lowercased()
            .replacingOccurrences(of: "<", with: "_")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ",", with: "")
    }
}
