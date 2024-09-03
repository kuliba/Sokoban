//
//  StandardSelectedCategoryDestinationNanoServices.swift
//
//
//  Created by Igor Malyarov on 02.09.2024.
//

public struct StandardSelectedCategoryDestinationNanoServices<Category, Latest, Operator, Success, Failure> {
    
    public let loadLatest: LoadLatest
    public let loadOperators: LoadOperators
    public let makeFailure: MakeFailure
    public let makeSuccess: MakeSuccess
    
    public init(
        loadLatest: @escaping LoadLatest,
        loadOperators: @escaping LoadOperators,
        makeFailure: @escaping MakeFailure,
        makeSuccess: @escaping MakeSuccess
    ) {
        self.loadLatest = loadLatest
        self.loadOperators = loadOperators
        self.makeFailure = makeFailure
        self.makeSuccess = makeSuccess
    }
}

public extension StandardSelectedCategoryDestinationNanoServices {
    
    typealias LoadLatestCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadLatest = (@escaping LoadLatestCompletion) -> Void
    
    typealias LoadOperatorsCompletion = (Result<[Operator], Error>) -> Void
    typealias LoadOperators = (@escaping LoadOperatorsCompletion) -> Void
    
    typealias MakeFailure = (@escaping (Failure) -> Void) -> Void
    
    typealias MakeSuccessPayload = MakeSelectedCategorySuccessPayload<Category, Latest, Operator>
    typealias MakeSuccess = (MakeSuccessPayload, @escaping (Success) -> Void) -> Void
}
