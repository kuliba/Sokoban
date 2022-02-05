//
//  LocalAgentEmptyMock.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import Foundation

class LocalAgentEmptyMock: LocalAgentProtocol {
    
    func store<T>(_ data: [T], serial: Int?) throws where T : Cachable {
        
    }
    
    func load<T>(type: T.Type) -> [T]? where T : Cachable {
        
        return nil
    }
    
    func clear<T>(type: T.Type) throws where T : Cachable {
        
    }
    
    func serial<T>(for type: T.Type) -> Int? where T : Cachable {

        return nil
    }  
}
