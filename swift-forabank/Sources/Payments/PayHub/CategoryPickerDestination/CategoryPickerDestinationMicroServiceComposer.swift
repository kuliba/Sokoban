//
//  CategoryPickerDestinationMicroServiceComposer.swift
//  
//
//  Created by Igor Malyarov on 02.09.2024.
//

public final class CategoryPickerDestinationMicroServiceComposer<Latest, Category, Operator, Success, Failure: Error> {
    
    private let nanoServices: NanoServices
    
    public init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = CategoryPickerDestinationNanoServices<Latest, Operator, Success, Failure>
}

public extension CategoryPickerDestinationMicroServiceComposer {
    
    func compose(
        with category: Category
    ) -> MicroService {
        
        return .init(makeDestination: makeDestination)
    }
    
    typealias MicroService = CategoryPickerDestinationMicroService<Category, Success, Failure>
}

private extension CategoryPickerDestinationMicroServiceComposer {
    
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
