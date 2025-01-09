//
//  Schedulers.swift
//
//
//  Created by Igor Malyarov on 07.11.2024.
//

import CombineSchedulers
import Foundation

public struct Schedulers {
    
    public let main: AnySchedulerOf<DispatchQueue>
    public let interactive: AnySchedulerOf<DispatchQueue>
    public let userInitiated: AnySchedulerOf<DispatchQueue>
    public let background: AnySchedulerOf<DispatchQueue>
    
    public init(
        main: AnySchedulerOf<DispatchQueue> = .main,
        interactive: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive),
        userInitiated: AnySchedulerOf<DispatchQueue> = .global(qos: .userInitiated),
        background: AnySchedulerOf<DispatchQueue> = .global(qos: .background)
    ) {
        self.main = main
        self.interactive = interactive
        self.userInitiated = userInitiated
        self.background = background
    }
}
