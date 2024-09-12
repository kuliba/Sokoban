//
//  SerialFallback.swift
//
//
//  Created by Igor Malyarov on 12.09.2024.
//

public final class SerialFallback<Serial, T, Failure: Error>
where Serial: Equatable {
    
    private let getSerial: () -> Serial?
    private let primary: Primary
    private let secondary: Secondary
    
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
    
    typealias PrimaryResult = Result<SerialStamped<Serial, [T]>, Failure>
    typealias PrimaryCompletion = (PrimaryResult) -> Void
    typealias Primary = (Serial?, @escaping PrimaryCompletion) -> Void
    
    typealias SecondaryResult = Result<[T], Failure>
    typealias SecondaryCompletion = (SecondaryResult) -> Void
    typealias Secondary = (@escaping SecondaryCompletion) -> Void
}

public extension SerialFallback {
    
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
