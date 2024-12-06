//
//  Model+performOrWaitForAuthorized.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 22.10.2024.
//

import Foundation
import Combine

extension Model {
    
    func performOrWaitForAuthorized(
        _ work: @escaping () -> Void
    ) -> AnyCancellable {
        
        if auth.value == .authorized {
            return Just(())
                .sink { work() }
        } else {
            return Publishers.CombineLatest(
                auth.map { $0 == .authorized },
                sessionState.map { $0.token != nil }
            )
            .map { $0.0 && $0.1 }
            .filter { $0 }
            .sink { _ in work() }
        }
    }
}
