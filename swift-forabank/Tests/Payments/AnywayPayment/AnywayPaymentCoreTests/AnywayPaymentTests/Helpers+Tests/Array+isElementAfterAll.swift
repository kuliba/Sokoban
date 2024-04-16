//
//  Array+isElementAfterAll.swift
//
//
//  Created by Igor Malyarov on 04.04.2024.
//

extension Array where Element: Identifiable {
    
    func isElementAfterAll(
        _ element: Element,
        inGroup group: [Element]
    ) -> Bool {
        
        isElementAfterAll(element.id, inGroup: group)
    }
    
    func isElementAfterAll(
        _ id: Element.ID,
        inGroup group: [Element]
    ) -> Bool {
        
        let indices = group.compactMap { item in firstIndex(where: { $0.id == item.id }) }
        
        guard let elementIndex = self.firstIndex(where: { $0.id == id })
        else { return false }
        
        return indices.allSatisfy { elementIndex > $0 }
    }
}
