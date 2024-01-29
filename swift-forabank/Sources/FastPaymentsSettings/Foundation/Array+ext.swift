//
//  Array+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

extension Array where Element: Identifiable {
    
    subscript(id: Element.ID) -> Element? {
        
        get { first { $0.id == id }}
        
        set(newValue) {
            
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            }
        }
    }
}
