//
//  StandardSelectedCategoryDestinationMicroServiceComposer.swift
//  
//
//  Created by Igor Malyarov on 02.09.2024.
//

public final class StandardSelectedCategoryDestinationMicroServiceComposer<Latest, Category, Operator, Success, Failure: Error> {
    
    private let nanoServices: NanoServices
    
    public init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = StandardSelectedCategoryDestinationNanoServices<Latest, Operator, Success, Failure>
}

public extension StandardSelectedCategoryDestinationMicroServiceComposer {
    
    func compose() -> MicroService {
        
        return .init(makeDestination: makeDestination)
    }
    
    typealias MicroService = StandardSelectedCategoryDestinationMicroService<Category, Success, Failure>
}

private extension StandardSelectedCategoryDestinationMicroServiceComposer {
    
    func makeDestination(
        category: Category,
        completion: @escaping MicroService.MakeDestinationCompletion
    ) {
        nanoServices.loadOperators { [weak self] in self?.handle($0, completion) }
    }
    
    func handle(
        _ result: Result<[Operator], Error>,
        _ completion: @escaping MicroService.MakeDestinationCompletion
    ) {
        switch result {
        case .failure:
            nanoServices.makeFailure { completion(.failure($0)) }

        case let .success(operators):
            if operators.isEmpty {
                nanoServices.makeFailure { completion(.failure($0)) }
            } else {
                nanoServices.loadLatest { [weak self] in
                
                    self?.nanoServices.makeSuccess(.init(
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
