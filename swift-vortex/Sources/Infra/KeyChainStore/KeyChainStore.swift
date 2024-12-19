//
//  KeyChainStore.swift
//  
//
//  Created by Igor Malyarov on 14.10.2023.
//

import Foundation

public typealias Cached<T> = (T, validUntil: Date)

public final class KeyChainStore<KeyTag, Key>
where KeyTag: RawRepresentable<String> {
    
    private let keyTag: KeyTag
    private let data: (Key) throws -> Data
    private let key: (Data) throws -> Key
    
    public init(
        keyTag: KeyTag,
        data: @escaping (Key) throws -> Data,
        key: @escaping (Data) throws -> Key
    ) {
        self.keyTag = keyTag
        self.data = data
        self.key = key
    }
    
    public func load() throws -> Cached<Key> {
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyTag.rawValue,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: 1
        ] as [CFString : Any]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == noErr,
              let data = result as? Data
        else {
            throw Error.dataNotFound
        }
        
        let decoded = try JSONDecoder().decode(Wrapped.self, from: data)
        let key = try key(decoded.data)
        
        return (key, decoded.validUntil)
    }
    
    public func save(_ cachedKey: Cached<Key>) throws {
        
        let encoded = try Wrapped(
            data: data(cachedKey.0),
            validUntil: cachedKey.validUntil
        )
        let data = try JSONEncoder().encode(encoded)
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyTag.rawValue,
            kSecValueData: data,
        ] as [CFString : Any]
        
        SecItemDelete(query as CFDictionary)
        
        let osStatus = SecItemAdd(query as CFDictionary, nil)
        
        guard osStatus == noErr
        else {
            let message: String = (SecCopyErrorMessageString(osStatus, nil) as? String) ?? "unknown OSStatus"
            throw Error.saveFailed(message)
        }
    }
    
    public func clear() {
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keyTag.rawValue,
        ] as [CFString : Any]
        
        SecItemDelete(query as CFDictionary)
    }
    
    enum Error: Swift.Error {
        
        case dataNotFound
        case saveFailed(String)
    }
    
    private struct Wrapped: Codable {
        
        let data: Data
        let validUntil: Date
    }
}

public extension KeyChainStore
where Key: RawRepresentable<Data> {
    
    convenience init(keyTag: KeyTag) {
        
        self.init(
            keyTag: keyTag,
            data: { $0.rawValue },
            key: { try .init(rawValue: $0) }
        )
    }
    
    struct RawError: Swift.Error {}
}

extension Optional {
    
    func get(orThrow error: Error) throws -> Wrapped {
        
        guard let wrapped = self else { throw error }
        
        return wrapped
    }
}

extension RawRepresentable {
    
    init(rawValue: RawValue) throws {
        
        self = try Self.init(rawValue: rawValue).get(orThrow: RawRepresentationError())
    }
}

struct RawRepresentationError: Swift.Error {}
