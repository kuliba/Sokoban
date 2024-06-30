//
//  LocalAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 20.01.2022.
//

import Foundation

class LocalAgent: LocalAgentProtocol {
    
    internal let context: Context
    internal var serials: [String: String]
    private let lock = NSRecursiveLock()

    init(context: Context) {
        
        self.context = context
        self.serials = [:]
        
        loadSerials()
    }
    
    //MARK: - Store
    
    func store<T>(_ data: T, serial: String? = nil) throws where T : Encodable {
        
        lock.lock()
        defer { lock.unlock() }
        
        let dataFileName = fileName(for: T.self)
        let data = try context.encoder.encode(data)
        try data.write(to: fileURL(with: dataFileName))
        
        serials[dataFileName] = serial
        let serialsData = try JSONEncoder().encode(serials)
        try serialsData.write(to: fileURL(with: context.serialsFileName))
    }

    //MARK: - Load
    
    func load<T>(type: T.Type) -> T? where T : Decodable {

        lock.lock()
        defer { lock.unlock() }
        
        let fileName = fileName(for: type)
        
        do {
            
            let data = try Data(contentsOf: fileURL(with: fileName))
            let decodedData = try context.decoder.decode(T.self, from: data)
            
            return decodedData
            
        } catch  {
            
            do {
               
                serials[fileName] = nil
                let serialsData = try JSONEncoder().encode(serials)
                try serialsData.write(to: fileURL(with: context.serialsFileName))
                
            } catch {
                
                //TODO: set logger
            }
            
            return nil
        }
    }
        
    //MARK: - Clear
    
    func clear<T>(type: T.Type) throws  {
        
        lock.lock()
        defer { lock.unlock() }
        
        let fileName = fileName(for: type)
        let dataFileURL = try fileURL(with: fileName)
        if context.fileManager.fileExists(atPath: dataFileURL.path) {
        
            try context.fileManager.removeItem(at: dataFileURL)
        }
        
        serials[fileName] = nil
        let serialsData = try JSONEncoder().encode(serials)
        let serialsFileURL = try fileURL(with: context.serialsFileName)
        try serialsData.write(to: serialsFileURL)
    }
    
    //MARK: - Serial
    
    func serial<T>(for type: T.Type) -> String? {
        
        let fileName = fileName(for: type)
        
        return serials[fileName]
    }
}

// MARK: - update

extension LocalAgent {
    
    func update<T: Codable>(
        with newData: T,
        serial: String?,
        using reduce: (T, T) -> T
    ) throws {
        
        lock.lock()
        defer { lock.unlock() }
        
        let existing = try load(type: T.self).get(orThrow: LoadError())
        let updated = reduce(existing, newData)
        try store(updated, serial: serial)
    }

    struct LoadError: Error {}
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
        
        lock.lock()
        defer { lock.unlock() }
        
        do {
            
            let serialsData = try Data(contentsOf: fileURL(with: context.serialsFileName))
            self.serials = try JSONDecoder().decode([String: String].self, from: serialsData)
            
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
