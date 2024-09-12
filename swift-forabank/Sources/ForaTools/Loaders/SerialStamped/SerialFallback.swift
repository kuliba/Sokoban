//
//  SerialFallback.swift
//
//
//  Created by Igor Malyarov on 12.09.2024.
//

/// A generic class that handles a primary and secondary operation based on an optional serial value.
/// If the primary operation succeeds and the serial matches, the secondary is called. Otherwise, the primary result is returned.
public final class SerialFallback<Serial, T, Failure: Error>
where Serial: Equatable {
    
    /// Retrieves the current serial value to be used in the fallback logic.
    private let getSerial: () -> Serial?
    
    /// The primary operation that takes an optional serial and returns a result via completion.
    private let primary: Primary
    
    /// The secondary operation that acts as a fallback if the primary fails or certain conditions are met.
    private let secondary: Secondary
    
    /// Initialises a `SerialFallback` with the required serial retrieval, primary, and secondary operations.
    /// - Parameters:
    ///   - getSerial: A closure that returns the current serial value.
    ///   - primary: The primary operation to be executed.
    ///   - secondary: The secondary fallback operation to be executed if necessary.
    public init(
        getSerial: @escaping () -> Serial?,
        primary: @escaping Primary,
        secondary: @escaping Secondary
    ) {
        self.getSerial = getSerial
        self.primary = primary
        self.secondary = secondary
    }
}

public extension SerialFallback {
    
    /// A typealias representing the result of the primary operation, which includes a stamped serial value.
    typealias PrimaryResult = Result<SerialStamped<Serial, [T]>, Failure>
    
    /// A typealias for the completion handler for the primary operation.
    typealias PrimaryCompletion = (PrimaryResult) -> Void
    
    /// A typealias representing the primary operation, which takes an optional serial and a completion handler.
    typealias Primary = (Serial?, @escaping PrimaryCompletion) -> Void
    
    /// A typealias representing the result of the secondary operation, which contains only a list of values.
    typealias SecondaryResult = Result<[T], Failure>
    
    /// A typealias for the completion handler for the secondary operation.
    typealias SecondaryCompletion = (SecondaryResult) -> Void
    
    /// A typealias representing the secondary operation, which takes a completion handler.
    typealias Secondary = (@escaping SecondaryCompletion) -> Void
}

public extension SerialFallback {
    
    /// Invokes the fallback mechanism by calling the primary operation and conditionally the secondary operation.
    /// - Parameter completion: The completion handler that will receive the final result of the fallback mechanism.
    /// If the serial is `nil`, the primary result is returned directly. If the serial is present and does not match the stamped result, the primary result is returned. Otherwise, the secondary operation is executed.
    func callAsFunction(
        completion: @escaping SecondaryCompletion
    ) {
        let serial = getSerial()
        primary(serial) { [weak self] in
            
            guard let self else { return }
            
            if serial == nil {
                completion($0.map(\.value))
            } else {
                switch $0 {
                case .failure:
                    self.secondary(completion)
                    
                case let .success(success):
                    if success.serial == serial {
                        self.secondary(completion)
                    } else {
                        completion(.success(success.value))
                    }
                }
            }
        }
    }
}
