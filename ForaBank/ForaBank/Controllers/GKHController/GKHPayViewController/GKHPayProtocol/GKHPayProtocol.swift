//
//  GKHPayProtocol.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import Foundation

public protocol Resource {
    init()
    static func fetch(completion: @escaping (Self) -> Void)
}

public extension Resource {
    static func fetch(completion: @escaping (Self) -> Void) {
        DispatchQueue.main.async() {
            completion(Self())
        }
    }
}

extension Array: Resource where Element: Resource {}
