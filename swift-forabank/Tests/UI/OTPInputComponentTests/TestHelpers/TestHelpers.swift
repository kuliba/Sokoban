//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 18.01.2024.
//

import Foundation

func anyMessage() -> String {
    
    UUID().uuidString
}

func connectivity() -> TickEvent {
    
    .failure(.connectivityError)
}

func connectivity() -> TickState {
    
    .idle(.connectivityError)
}

func idle() -> TickState {
    
    .idle(nil)
}

func idleConnectivity() -> TickState {
    
    .idle(.connectivityError)
}

func running(
    _ remaining: Int
) -> TickState {
    
    .running(remaining: remaining)
}

func serverError(
    _ message: String = anyMessage()
) -> TickEvent {
    
    .failure(.serverError(message))
}

func serverError(
    _ message: String = anyMessage()
) -> TickState {
    
    .idle(.serverError(message))
}
