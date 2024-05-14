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
    ) throws {
        
        DispatchQueue.global(qos: .background).async { [localAgent] in
            
            // TODO: replace with injectable service
            try? localAgent.store(data.makeCache(), serial: serial)
        }
    }
}

// MARK: - Cache

struct CachingSberOperator: Codable {
    
    let id: String
    let icon: String?
    let inn: String?
    let name: String
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
            icon: sberOperator.icon, 
            inn: sberOperator.inn,
            name: sberOperator.title,
            sortedOrder: index
        )
    }
}

// MARK: - Sort

// TODO: add tests
extension SberOperator {
    
    func precedes(_ other: Self) -> Bool {
        
        guard title != other.title else {
            return title.customLexicographicallyPrecedes(other.title)
        }
        
        #warning("extract to helper")
        switch (inn, other.inn) {
        case let (.some(inn), .some(otherINN)):
            return inn.customLexicographicallyPrecedes(otherINN)
            
        case (.none, _):
            return false
            
        case (_, .none):
            return true
        }
    }
}

private extension String {
    
    /// Custom method to compare strings based on character priorities: Cyrillic, Latin, Numbers, other.
    /// - Warning: Method is quite expensive.
    func customLexicographicallyPrecedes(
        _ other: String
    ) -> Bool {
        
        // TODO: improve. Schwarzian transform?
        
        let minLength = min(self.count, other.count)
        
        for i in 0..<minLength {
            
            let selfChar = self[index(startIndex, offsetBy: i)]
            let otherChar = other[other.index(startIndex, offsetBy: i)]
            
            if selfChar.characterSortPriority() != otherChar.characterSortPriority() {
                return selfChar.characterSortPriority() < otherChar.characterSortPriority()
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
        
        let s = String(self)
        
        if s.range(of: "\\p{InCyrillic}", options: .regularExpression) != nil {
            return 1  // Priority 1 for Cyrillic characters
        } else if s.range(of: "[A-Za-z]", options: .regularExpression) != nil {
            return 2  // Priority 2 for Latin characters
        } else if s.range(of: "[0-9]", options: .regularExpression) != nil {
            return 3  // Priority 3 for numbers
        }
        
        return 4
    }
}
