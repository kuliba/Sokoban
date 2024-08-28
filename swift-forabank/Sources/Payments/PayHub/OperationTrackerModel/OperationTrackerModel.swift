//
//  OperationTrackerModel.swift
//
//
//  Created by Igor Malyarov on 28.08.2024.
//

import CombineSchedulers
import ForaTools
import Foundation
import RxViewModel

/// A typealias for the `RxViewModel` that manages the state, events, and effects of an operation tracking process.
///
/// This view model is designed to handle different states of an operation (e.g., not started, loading, failed, loaded)
/// and to manage the associated side effects. The model can be initialized with different types of loaders depending on the needs
/// of the application.
public typealias OperationTrackerModel = RxViewModel<OperationTrackerState, OperationTrackerEvent, OperationTrackerEffect>

public extension OperationTrackerModel {
    
    /// Initialises an `OperationTrackerModel` with a `Bool`-based loader.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the operation tracker. Defaults to `.notStarted`.
    ///   - load: A closure that performs the operation. The closure takes a completion handler that
    ///           should be called with `true` if the operation was successful, and `false` otherwise.
    ///   - scheduler: The scheduler on which to perform state changes and effects.
    ///
    /// This initialiser is useful when the result of the operation can be expressed as a simple `Bool`
    /// indicating success or failure.
    convenience init(
        initialState: OperationTrackerState = .notStarted,
        load: @escaping (@escaping (Bool) -> Void) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        let reducer = OperationTrackerReducer()
        let effectHandler = OperationTrackerEffectHandler(load: load)
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    /// Initialises an `OperationTrackerModel` with a generic `Result`-based loader.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the operation tracker. Defaults to `.notStarted`.
    ///   - load: A closure that performs the operation. The closure takes a completion handler that
    ///           should be called with a `Result` containing the loaded data or an `Error`.
    ///   - scheduler: The scheduler on which to perform state changes and effects.
    ///
    /// This initialiser is useful when the operation returns a `Result` type. The success case is
    /// converted into `true` if the `Result` is successful (i.e., `Result.success`), and `false` if the
    /// `Result` is a failure (i.e., `Result.failure`) for state management.
    convenience init<T>(
        initialState: OperationTrackerState = .notStarted,
        load: @escaping (@escaping (Result<T, Error>) -> Void) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.init(
            initialState: initialState,
            load: { completion in load { completion((try? $0.get())) }},
            scheduler: scheduler
        )
    }
    
    /// Initialises an `OperationTrackerModel` with an optional value-based loader.
    ///
    /// - Parameters:
    ///   - initialState: The initial state of the operation tracker. Defaults to `.notStarted`.
    ///   - load: A closure that performs the operation. The closure takes a completion handler that
    ///           should be called with an optional value. The success state is determined by whether the
    ///           value is `nil` (failure) or non-`nil` (success).
    ///   - scheduler: The scheduler on which to perform state changes and effects.
    ///
    /// This initialiser is useful when the operation provides an optional value, where a `nil` value
    /// indicates failure, and a non-`nil` value indicates success.
    convenience init<T>(
        initialState: OperationTrackerState = .notStarted,
        load: @escaping (@escaping (T?) -> Void) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.init(
            initialState: initialState,
            load: { completion in load { completion($0 != nil) }},
            scheduler: scheduler
        )
    }
}
