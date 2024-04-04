//
//  Array+isElementAfterAll.swift
//
//
//  Created by Igor Malyarov on 04.04.2024.
//

extension Array where Element: Identifiable {
    
    func isElementAfterAll(
        _ element: Element,
        inGroup set: [Element]
    ) -> Bool {
        
        let indices = set.compactMap { item in firstIndex(where: { $0.id == item.id }) }
        
        guard let elementIndex = self.firstIndex(where: { $0.id == element.id })
        else { return false }
        
        return indices.allSatisfy { elementIndex > $0 }
    }
}
