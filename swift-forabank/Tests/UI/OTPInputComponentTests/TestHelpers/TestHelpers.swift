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

func connectivity() -> TickState.Status {
    
    .failure(.connectivityError)
}

func idle() -> TickState {
    
    .init(.idle)
}

func idleConnectivity() -> TickState {
    
    .init(.idle, status: connectivity())
}

func running(
    _ remaining: Int
) -> TickState {
    
    .init(.running(remaining: remaining))
}

func runningConnectivity(
    _ remaining: Int
) -> TickState {
    
    .init(.running(remaining: remaining), status: connectivity())
}

func serverError(
    _ message: String = anyMessage()
) -> TickEvent {
    
    .failure(.serverError(message))
}

func serverError(
    _ message: String = anyMessage()
) -> TickState.Status {
    
    .failure(.serverError(message))
}
