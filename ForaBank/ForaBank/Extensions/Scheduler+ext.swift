//
//  Scheduler+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.10.2024.
//

import Combine
import Foundation

extension Scheduler {
    
    // Typealiases for completion handlers
    typealias Completion<Response> = (_ response: Response) -> Void
    typealias CompletionWithoutResponse = () -> Void
    
    // Typealiases for work closures
    typealias WorkWithPayloadAndResponse<Payload, Response> = (
        _ payload: Payload,
        _ completion: @escaping Completion<Response>
    ) -> Void
    
    typealias WorkWithPayload<Payload> = (
        _ payload: Payload,
        _ completion: @escaping CompletionWithoutResponse
    ) -> Void
    
    typealias WorkWithResponse<Response> = (
        _ completion: @escaping Completion<Response>
    ) -> Void
    
    typealias WorkWithoutPayloadAndResponse = (
        _ completion: @escaping CompletionWithoutResponse
    ) -> Void
    
    /// Schedules work with a payload and a response, and then calls the completion handler with the response.
    ///
    /// - Parameters:
    ///   - work: The work to be performed, accepting a payload and a completion handler with a response.
    ///   - payload: The payload to pass to the work.
    ///   - completion: The completion handler to call with the response after the work is completed.
    func perform<Payload, Response>(
        work: @escaping WorkWithPayloadAndResponse<Payload, Response>,
        with payload: Payload,
        completion: @escaping Completion<Response>
    ) {
        self.schedule { work(payload, completion) }
    }
    
    /// Schedules work with a payload, and then calls the completion handler.
    ///
    /// - Parameters:
    ///   - work: The work to be performed, accepting a payload and a completion handler without a response.
    ///   - payload: The payload to pass to the work.
    ///   - completion: The completion handler to call after the work is completed.
    func perform<Payload>(
        work: @escaping WorkWithPayload<Payload>,
        with payload: Payload,
        completion: @escaping CompletionWithoutResponse
    ) {
        self.schedule { work(payload, completion) }
    }
    
    /// Schedules work without a payload but with a response, and then calls the completion handler with the response.
    ///
    /// - Parameters:
    ///   - work: The work to be performed, accepting a completion handler with a response.
    ///   - completion: The completion handler to call with the response after the work is completed.
    func perform<Response>(
        work: @escaping WorkWithResponse<Response>,
        completion: @escaping Completion<Response>
    ) {
        self.schedule { work(completion) }
    }
    
    /// Schedules work without a payload or response, and then calls the completion handler.
    ///
    /// - Parameters:
    ///   - work: The work to be performed, accepting a completion handler without a response.
    ///   - completion: The completion handler to call after the work is completed.
    func perform(
        work: @escaping WorkWithoutPayloadAndResponse,
        completion: @escaping CompletionWithoutResponse
    ) {
        self.schedule { work(completion) }
    }
}

extension Scheduler {
    
    /// Returns a new closure that schedules the original work with a payload and a response.
    ///
    /// - Parameter work: The original work closure accepting a payload and a completion handler with a response.
    /// - Returns: A new work closure that schedules the original work using the scheduler.
    func scheduled<Payload, Response>(
        _ work: @escaping WorkWithPayloadAndResponse<Payload, Response>
    ) -> WorkWithPayloadAndResponse<Payload, Response> {
        
        return { payload, completion in
            
            self.schedule { work(payload, completion) }
        }
    }
    
    /// Returns a new closure that schedules the original work with a payload and no response.
    ///
    /// - Parameter work: The original work closure accepting a payload and a completion handler without a response.
    /// - Returns: A new work closure that schedules the original work using the scheduler.
    func scheduled<Payload>(
        _ work: @escaping WorkWithPayload<Payload>
    ) -> WorkWithPayload<Payload> {
        
        return { payload, completion in
            
            self.schedule { work(payload, completion) }
        }
    }
    
    /// Returns a new closure that schedules the original work without a payload but with a response.
    ///
    /// - Parameter work: The original work closure accepting a completion handler with a response.
    /// - Returns: A new work closure that schedules the original work using the scheduler.
    func scheduled<Response>(
        _ work: @escaping WorkWithResponse<Response>
    ) -> WorkWithResponse<Response> {
        
        return { completion in
            
            self.schedule { work(completion) }
        }
    }
    
    /// Returns a new closure that schedules the original work without a payload or a response.
    ///
    /// - Parameter work: The original work closure accepting a completion handler without a response.
    /// - Returns: A new work closure that schedules the original work using the scheduler.
    func scheduled(
        _ work: @escaping WorkWithoutPayloadAndResponse
    ) -> WorkWithoutPayloadAndResponse {
        
        return { completion in
            
            self.schedule { work(completion) }
        }
    }
}
