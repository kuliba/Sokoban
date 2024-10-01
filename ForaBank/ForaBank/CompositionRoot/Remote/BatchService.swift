//
//  BatchService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.09.2024.
//

/// A service that asynchronously processes a batch of payloads.
///
/// This service processes each `Payload` in the provided array asynchronously, such as performing network requests.
/// After all payloads have been processed, it calls the `completion` closure with any payloads that failed.
///
/// - Parameters:
///   - payloads: An array of `Payload` instances to be processed.
///   - completion: A closure called upon completion of all processing tasks.
///                 It receives an array of payloads that failed during processing.
typealias BatchService<Payload> = (
    _ payloads: [Payload],
    _ completion: @escaping (_ failedPayloads: [Payload]) -> Void
) -> Void
