//
//  RestartablePayment.swift
//  
//
//  Created by Igor Malyarov on 27.05.2024.
//

public protocol RestartablePayment {
    
    var shouldRestart: Bool { get set }
}
