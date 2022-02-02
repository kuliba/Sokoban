//
//  LocalAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 20.01.2022.
//

import Foundation

class LocalAgent: LocalAgentProtocol {
    
    private let context: Context
    private var serials: [String: Int]
    
    init(context: Context) {
        
        self.context = context
        self.serials = [:]
        
        loadSerials()
    }
    
    //MARK: - Store
    
    func store<T>(_ data: T, serial: Int? = nil) throws where T : Cachable {
        
        let dataFileName = fileName(for: T.self)
        let data = try context.encoder.encode(data)
        try data.write(to: fileURL(with: dataFileName))
        
        serials[dataFileName] = serial
        let serialsData = try JSONEncoder().encode(serials)
        try serialsData.write(to: fileURL(with: context.serialsFileName))
    }
    
    func store<T>(_ data: T, serial: Int? = nil) throws where T : Collection, T: Encodable, T.Element : Cachable {
        
        let dataFileName = fileName(for: T.self)
        let data = try context.encoder.encode(data)
        try data.write(to: fileURL(with: dataFileName))
        
        serials[dataFileName] = serial
        let serialsData = try JSONEncoder().encode(serials)
        try serialsData.write(to: fileURL(with: context.serialsFileName))
    }
    
    //MARK: - Load
    
    func load<T>(type: T.Type) -> T? where T : Cachable {

        let fileName = fileName(for: type)
        
        do {
            
            let data = try Data(contentsOf: fileURL(with: fileName))
            let decodedData = try context.decoder.decode(T.self, from: data)
            
            return decodedData
            
        } catch  {
            
            return nil
        }
    }
    
    func load<T>(type: T.Type) -> T? where T : Collection, T : Decodable, T.Element : Cachable {
        
        let fileName = fileName(for: type)
        
        do {
            
            let data = try Data(contentsOf: fileURL(with: fileName))
            let decodedData = try context.decoder.decode(T.self, from: data)
            
            return decodedData
            
        } catch  {
            
            return nil
        }
    }
    
    //MARK: - Clear
    
    func clear<T>(type: T.Type) throws where T : Cachable {
        
        let fileName = fileName(for: type)
        try context.fileManager.removeItem(at: fileURL(with: fileName))
        
        serials[fileName] = nil
        let serialsData = try JSONEncoder().encode(serials)
        try serialsData.write(to: fileURL(with: context.serialsFileName))
    }
    
    func clear<T>(type: T.Type) throws where T : Collection, T.Element : Cachable {
        
        let fileName = fileName(for: type)
        try context.fileManager.removeItem(at: fileURL(with: fileName))
        
        serials[fileName] = nil
        let serialsData = try JSONEncoder().encode(serials)
        try serialsData.write(to: fileURL(with: context.serialsFileName))
    }
    
    //MARK: - Serial
    
    func serial<T>(for type: T.Type) -> Int? where T : Cachable {
        
        let fileName = fileName(for: type)
        
        return serials[fileName]
    }
    
    func serial<T>(for type: T.Type) -> Int? where T : Collection, T.Element : Cachable {
        
        let fileName = fileName(for: type)
        
        return serials[fileName]
    }
}

//MARK: - Internal Helpers

internal extension LocalAgent {
    
    func rootFolderURL() throws -> URL {
        
        return try context.fileManager.rootFolderURL(with: context.cacheFolderName)
    }
    
    func fileURL(with name: String) throws -> URL {
        
        return try rootFolderURL().appendingPathComponent(name)
    }
    
    func loadSerials() {
        
        do {
            
            let serialsData = try Data(contentsOf: fileURL(with: context.serialsFileName))
            self.serials = try JSONDecoder().decode([String: Int].self, from: serialsData)
            
        } catch {
            
            self.serials = [:]
        }
    }
}

//MARK: - Types

extension LocalAgent {
    
    struct Context {
        
        let cacheFolderName: String
        let serialsFileName = "serials.json"
        let encoder: JSONEncoder
        let decoder: JSONDecoder
        let fileManager: FileManager
    }
}
