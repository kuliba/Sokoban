//
//  Sequence+Extension.swift
//  
//
//  Created by Igor Malyarov on 18.10.2021.
//

import Foundation

extension Sequence {
    
    /// Sort Sequence by element keyPath.
    ///
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted { a, b in
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
    
    /// Sort Sequence by element keyPath for optional element.
    ///
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T?>,
        using comparator: (T, T) -> Bool = (<),
        ifNil: Bool = false
    ) -> [Element] {
        sorted { a, b in
            guard let a = a[keyPath: keyPath],
                  let b = b[keyPath: keyPath]
            else { return ifNil }
            
            return comparator(a, b)
        }
    }
}
