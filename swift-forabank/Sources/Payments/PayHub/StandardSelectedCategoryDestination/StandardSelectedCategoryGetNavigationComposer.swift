//
//  StandardSelectedCategoryGetNavigationComposer.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

public final class StandardSelectedCategoryGetNavigationComposer<Category, Latest, Operator, Success, Failure: Error> {
    
    private let nanoServices: NanoServices
    
    public init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = StandardSelectedCategoryDestinationNanoServices<Category, Latest, Operator, Success, Failure>
}

public extension StandardSelectedCategoryGetNavigationComposer {
    
    func makeDestination(
        category: Category,
        completion: @escaping (Result<Success, Failure>) -> Void
    ) {
        nanoServices.loadOperators { self.handle($0, category, completion) }
    }
}

private extension StandardSelectedCategoryGetNavigationComposer {
    
    func handle(
        _ result: Result<[Operator], Error>,
        _ category: Category,
        _ completion: @escaping (Result<Success, Failure>) -> Void
    ) {
        switch result {
        case .failure:
            nanoServices.makeFailure { completion(.failure($0)) }
            
        case let .success(operators):
            if operators.isEmpty {
                nanoServices.makeFailure { completion(.failure($0)) }
            } else {
                nanoServices.loadLatest {
                    
                    self.nanoServices.makeSuccess(.init(
                        category: category,
                        latest: (try? $0.get()) ?? [],
                        operators: operators
                    )) {
                        completion(.success($0))
                    }
                }
            }
        }
    }
}
