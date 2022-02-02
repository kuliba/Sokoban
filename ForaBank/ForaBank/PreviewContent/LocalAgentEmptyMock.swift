//
//  LocalAgentEmptyMock.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation

class LocalAgentEmptyMock: LocalAgentProtocol {
    
    func store<T>(_ data: T, serial: Int?) throws where T : Cachable {
        
    }
    
    func store<T>(_ data: T, serial: Int?) throws where T : Collection, T : Encodable, T.Element : Cachable {
        
    }
    
    func load<T>(type: T.Type) -> T? where T : Cachable {
        
        return nil
    }
    
    func load<T>(type: T.Type) -> T? where T : Collection, T : Decodable, T.Element : Cachable {
        
        return nil
    }
    
    func clear<T>(type: T.Type) throws where T : Cachable {
        
    }
    
    func clear<T>(type: T.Type) throws where T : Collection, T.Element : Cachable {
        
    }
    
    func serial<T>(for type: T.Type) -> Int? where T : Cachable {

        return nil
    }
    
    func serial<T>(for type: T.Type) -> Int? where T : Collection, T.Element : Cachable {
        
        return nil
    }
}
