//
//  OperatorProviderLoadResultTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.08.2024.
//

@testable import ForaBank
import XCTest

final class OperatorProviderLoadResultTests: XCTestCase {
    
    func test_shouldSetToNoneOnBothEmpty() {
        
        XCTAssertNoDiff(makeResult([], []), .none)
    }
    
    func test_shouldSetToProviderOnSingleProvider() {
        
        let provider = makeProvider()
        
        XCTAssertNoDiff(makeResult([], [provider]), .provider(provider))
    }
    
    func test_shouldSetToMixedOnEmptyOperatorTwoProviders() {
        
        let provider1 = makeProvider()
        let provider2 = makeProvider()
        
        XCTAssertNoDiff(
            makeResult([], [provider1, provider2]),
            .mixed(.init(.provider(provider1), .provider(provider2)))
        )
    }
    
    func test_shouldSetToOperatorOnSingleOperator() {
        
        let `operator` = makeOperator()
        
        XCTAssertNoDiff(makeResult([`operator`], []), .operator(`operator`))
    }
    
    func test_shouldSetToMixesOnOneOperatorOneProvider() {
        
        let `operator` = makeOperator()
        let provider = makeProvider()
        
        XCTAssertNoDiff(
            makeResult([`operator`], [provider]),
            .mixed(.init(.operator(`operator`), .provider(provider)))
        )
    }
    
    func test_shouldSetToMixedOnOneOperatorTwoProviders() {
        
        let `operator` = makeOperator()
        let provider1 = makeProvider()
        let provider2 = makeProvider()
        
        XCTAssertNoDiff(
            makeResult([`operator`], [provider1, provider2]),
            .mixed(.init(.operator(`operator`), .provider(provider1), .provider(provider2)))
        )
    }
    
    func test_shouldSetToMultipleOnTwoOperatorsEmptyProviders() {
        
        let operator1 = makeOperator()
        let operator2 = makeOperator()
        
        XCTAssertNoDiff(
            makeResult([operator1, operator2], []),
            .multiple(.init(operator1, operator2))
        )
    }
    
    func test_shouldSetToMixedOnTwoOperatorsOneProvider() {
        
        let operator1 = makeOperator()
        let operator2 = makeOperator()
        let provider = makeProvider()
        
        XCTAssertNoDiff(
            makeResult([operator1, operator2], [provider]),
            .mixed(.init(.operator(operator1), .operator(operator2), .provider(provider)))
        )
    }
    
    func test_shouldSetToMixedOnTwoOperatorsTwoProviders() {
        
        let operator1 = makeOperator()
        let operator2 = makeOperator()
        let provider1 = makeProvider()
        let provider2 = makeProvider()
        
        XCTAssertNoDiff(
            makeResult([operator1, operator2], [provider1, provider2]),
            .mixed(.init(.operator(operator1), .operator(operator2), .provider(provider1), .provider(provider2)))
        )
    }
    
    // MARK: - Helpers
    
    private typealias Operator = Int
    private typealias Provider = String
    private typealias SUT = OperatorProviderLoadResult<Operator, Provider>
    
    private func makeResult(
        _ operators: [Operator]?,
        _ providers: [Provider]?
    ) -> SUT {
        
        return .init(operators: operators, providers: providers)
    }
    
    private func makeOperator(
        _ value: Int = .random(in: 1...100)
    ) -> Operator {
        
        return value
    }
    
    private func makeProvider(
        _ value: String = anyMessage()
    ) -> Provider {
        
        return value
    }
}
