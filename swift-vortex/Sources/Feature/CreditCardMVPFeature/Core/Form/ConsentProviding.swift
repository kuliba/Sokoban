//
//  ConsentProviding.swift
//  
//
//  Created by Igor Malyarov on 20.03.2025.
//

/// Protocol defining an object that can provide consent status.
public protocol ConsentProviding {
    
    /// Whether consent has been granted.
    var isGranted: Bool { get }
}
