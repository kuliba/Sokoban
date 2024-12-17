//
//  GCDHelper.swift
//  ForaBank
//
//  Created by Mikhail on 30.11.2021.
//

import Foundation

/// GCD to perform task in main thread
public func runOnMainQueue(_ block: () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync(execute: block)
    }
}

/// GCD to execute a block after a given delay
public func runBlockAfterDelay(_ waitInterval: TimeInterval, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + waitInterval, execute: block)
}
