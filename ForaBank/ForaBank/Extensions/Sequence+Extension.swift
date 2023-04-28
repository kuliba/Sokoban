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
    
}
