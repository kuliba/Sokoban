//
//  LocalAgentProtocol.swift
//  ForaBank
//
//  Created by Max Gribov on 20.01.2022.
//

import Foundation

protocol LocalAgentProtocol {
    
    func store<T>(_ data: T, serial: String?) throws where T : Encodable
    func load<T>(type: T.Type) -> T? where T : Decodable
    func clear<T>(type: T.Type) throws
    func serial<T>(for type: T.Type) -> String?
    
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
