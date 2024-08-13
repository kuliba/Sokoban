//
//  CacheSberOperator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import Foundation
import OperatorsListComponents

extension Model {
    
    func cache(
        _ data: [SberOperator],
        serial: String?
    ) {
        let log = LoggerAgent().log
        log(.debug, .cache, "Data count: \(data.count)", #file, #line)
        
        let cache = data.makeCache()
        log(.debug, .cache, "Cache count: \(cache.count)", #file, #line)
        
        loggingCache(
            cache,
            serial: serial,
            save: localAgent.store,
            log: { log(.error, .cache, $0, $1, $2) }
        )
    }
}

// MARK: - Cache

struct CachingSberOperator: Codable, Equatable {
    
    let id: String
    let inn: String
    let md5Hash: String?
    let title: String
    let sortedOrder: Int
}

private extension Array where Element == SberOperator {
    
    /// Sort and map.
    /// - Warning: Expensive operation.
    func makeCache() -> [CachingSberOperator] {
        
        self.sorted { $0.precedes($1) }
            .enumerated()
            .map(CachingSberOperator.init(_:_:))
    }
}

private extension CachingSberOperator {
    
    init(_ index: Int, _ sberOperator: SberOperator) {
        
        self.init(
            id: sberOperator.id,
            inn: sberOperator.inn,
            md5Hash: sberOperator.md5Hash,
            title: sberOperator.title,
            sortedOrder: index
        )
    }
}

// MARK: - Sort

extension SberOperator {
    
    func precedes(_ other: Self) -> Bool {
        
        guard title == other.title
        else {
            return title.customLexicographicallyPrecedes(other.title)
        }
        
        return inn.customLexicographicallyPrecedes(other.inn)
    }
}

extension String {
    
    /// Custom method to compare strings based on character priorities: Cyrillic, Latin, Numbers, other.
    /// - Warning: Method is quite expensive.
    func customLexicographicallyPrecedes(
        _ other: String
    ) -> Bool {
        
        // Precompute priorities for both strings
        let selfPriorities = self.map { $0.characterSortPriority() }
        let otherPriorities = other.map { $0.characterSortPriority() }
        
        let minLength = min(self.count, other.count)
        
        for i in 0..<minLength {
            
            let selfChar = self[index(startIndex, offsetBy: i)]
            let otherChar = other[other.index(other.startIndex, offsetBy: i)]
            
            if selfPriorities[i] != otherPriorities[i] {
                return selfPriorities[i] < otherPriorities[i]
            } else if selfChar != otherChar {
                return selfChar < otherChar
            }
        }
        
        return self.count < other.count
    }
}

private extension Character {
    
    /// Determine the custom priority of the character.
    func characterSortPriority() -> Int {
        
        switch self {
        case "\u{0400}"..."\u{04FF}":
            return 1  // Priority 1 for Cyrillic characters
        case "A"..."Z", "a"..."z":
            return 2  // Priority 2 for Latin characters
        case "0"..."9":
            return 3  // Priority 3 for numbers
        default:
            return 4  // Priority 4 for other characters
        }
    }
}
