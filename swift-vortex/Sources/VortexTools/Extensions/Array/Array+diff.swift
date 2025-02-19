//
//  Array+diff.swift
//
//
//  Created by Igor Malyarov on 14.01.2025.
//

public extension Array where Element: Identifiable {
    
    /// Returns a dictionary of elements with differing values at the specified key path compared to another array.
    /// - Parameters:
    ///   - other: The array to compare against.
    ///   - keyPath: The key path of the value to compare.
    /// - Returns: A dictionary mapping `Element.ID` to differing values.
    func diff<Value: Equatable>(
        _ other: Self,
        keyPath: KeyPath<Element, Value>
    ) -> [Element.ID: Value] {
        
        guard !self.isEmpty, !other.isEmpty 
        else {
            return .init(uniqueKeysWithValues: self.map { ($0.id, $0[keyPath: keyPath]) })
        }
        
        let otherDict = Dictionary(uniqueKeysWithValues: other.map { ($0.id, $0) })
        
        return self.reduce(into: [Element.ID: Value]()) { differences, element in
            
            guard let otherElement = otherDict[element.id] 
            else {
                differences[element.id] = element[keyPath: keyPath]
                return
            }
            
            let selfValue = element[keyPath: keyPath]
            let otherValue = otherElement[keyPath: keyPath]
            
            if selfValue != otherValue {
                
                differences[element.id] = selfValue
            }
        }
    }
}

