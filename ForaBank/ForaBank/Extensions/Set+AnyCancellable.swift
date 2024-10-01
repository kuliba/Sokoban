//
//  Set+AnyCancellable.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.09.2024.
//

import Combine

extension Set where Element == AnyCancellable {
    
    /// Inserts the cancellable work into the set and immediately runs the work.
    ///
    /// This method wraps the closure in an `AnyCancellable` and inserts it into the set to ensure
    /// that the operation is retained and can be canceled later. After inserting, it immediately
    /// runs the closure.
    ///
    /// - Parameter work: A closure that performs the work to be saved and run.
    mutating func saveAndRun(
        _ work: @escaping () -> Void
    ) {
        insert(.init(work))
        work()
    }
}
