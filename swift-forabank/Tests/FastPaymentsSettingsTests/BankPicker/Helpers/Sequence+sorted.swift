//
//  Sequence+sorted.swift
//  
//
//  Created by Igor Malyarov on 31.12.2023.
//

extension Sequence {
    
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>
    ) -> [Self.Element] {

        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
