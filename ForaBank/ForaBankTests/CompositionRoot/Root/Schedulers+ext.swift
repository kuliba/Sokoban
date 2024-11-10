//
//  Schedulers+ext.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.11.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

extension PayHubUI.Schedulers {
    
    static let immediate: Self = .init(
        main: .immediate,
        interactive: .immediate,
        userInitiated: .immediate,
        background: .immediate
    )
    
    static let test: Self = .init(
        main: DispatchQueue.test.eraseToAnyScheduler(),
        interactive: DispatchQueue.test.eraseToAnyScheduler(),
        userInitiated: DispatchQueue.test.eraseToAnyScheduler(),
        background: DispatchQueue.test.eraseToAnyScheduler()
    )
}
