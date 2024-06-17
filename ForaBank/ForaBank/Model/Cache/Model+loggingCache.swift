//
//  Model+loggingCache.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.05.2024.
//

import Foundation

extension Model {
    
    func loggingCache<T: Encodable>(
        _ data: T,
        serial: String?,
        save: @escaping (T, String?) throws -> Void,
        log: @escaping (String, StaticString, UInt) -> Void,
        queue: DispatchQueue = DispatchQueue.global(qos: .background),
        file: StaticString = #file,
        line: UInt = #line
    ) {
        queue.async {
 
            do {
                try save(data, serial)
            } catch {
                log("Cache failure: \(error)", file, line)
            }
        }
    }
}
