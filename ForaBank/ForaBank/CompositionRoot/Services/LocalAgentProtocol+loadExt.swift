//
//  LocalAgentProtocol+loadExt.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

extension LocalAgentProtocol {
    
    func load<T: Decodable>(type: T.Type) -> (T, String?)? {
        
        return load(type: type).map { ($0, serial(for: type)) }
    }
}
