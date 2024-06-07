//
//  DispatchQueue+delay.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 08.05.2024.
//

import Foundation

extension DispatchQueue {
    
    func delay(
        for timeInterval: DispatchTimeInterval,
        execute action: @escaping () -> Void
    ) {
        asyncAfter(
            deadline: .now() + timeInterval,
            execute: action
        )
    }
}
