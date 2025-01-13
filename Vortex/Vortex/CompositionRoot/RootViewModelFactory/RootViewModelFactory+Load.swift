//
//  RootViewModelFactory+Load.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.09.2024.
//

extension RootViewModelFactory {
    
    typealias Load<T> = (@escaping (T?) -> Void) -> Void
}
