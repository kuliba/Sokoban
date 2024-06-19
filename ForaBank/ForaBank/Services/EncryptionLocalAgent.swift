//
//  EncryptionLocalAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 24.07.2023.
//

import Foundation

final class EncryptionLocalAgent<E>: LocalAgent where E: EncryptionAgent {
    
    private let encryptionAgent: E
    private let lock = NSLock()
    
    init(context: Context, encryptionAgent: E) {
        self.encryptionAgent = encryptionAgent
        super.init(context: context)
    }
    
    override func store<T>(_ data: T, serial: String? = nil) throws where T : Encodable {
        
        lock.lock()
        defer { lock.unlock() }
        
        let dataFileName = fileName(for: T.self)
        let data = try context.encoder.encode(data)
        let encryptedData = try encryptionAgent.encrypt(data)
        try encryptedData.write(to: fileURL(with: dataFileName))
        
        serials[dataFileName] = serial
        let serialsData = try JSONEncoder().encode(serials)
        try serialsData.write(to: fileURL(with: context.serialsFileName))
    }
    
    override func load<T>(type: T.Type) -> T? where T : Decodable {
        
        lock.lock()
        defer { lock.unlock() }
        
        let fileName = fileName(for: type)
        
        do {
            
            let data = try Data(contentsOf: fileURL(with: fileName))
            let decryptedData = try encryptionAgent.decrypt(data)
                      
            return try context.decoder.decode(T.self, from: decryptedData)
            
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
}
