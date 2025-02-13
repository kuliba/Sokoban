//
//  PaymentsViewModelTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 12.02.2025.
//

@testable import Vortex
import XCTest

final class PaymentsViewModelTests: XCTestCase {
    
    func test_modelPaymentProcessResponseWithConfirmResult_shouldRouteSetToConfirm() throws {
        
        let (sut, model, routeSpy) = makeSUT()
        
        model.sendAndWait(Response.confirm)
        
        XCTAssertNoDiff(routeSpy.values.equatable, [nil, .confirm])
    }
    
    func test_modelPaymentProcessResponseWithSuccessResult_shouldRouteSetToSuccess() throws {
        
        let (sut, model, routeSpy) = makeSUT()
        
        model.sendAndWait(Response.success)
        
        XCTAssertNoDiff(routeSpy.values.equatable, [nil, .success])
    }
    
    func test_modelWithConfirmResult_dismiss_shouldRouteSetToNil() throws {
        
        let (sut, model, routeSpy) = makeSUT()
        
        model.sendAndWait(Response.confirm)
        sut.dismiss()
        
        XCTAssertNoDiff(routeSpy.values.equatable, [nil, .confirm, nil])
    }
    
    func test_modelWithSuccessResult_dismiss_shouldRouteSetToNil() throws {
        
        let (sut, model, routeSpy) = makeSUT()
        
        model.sendAndWait(Response.success)
        sut.dismiss()
        
        XCTAssertNoDiff(routeSpy.values.equatable, [nil, .success, nil])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsViewModel
    private typealias Response = ModelAction.Payment.Process.Response
    private typealias RouteSpy = ValueSpy<SUT.Route?>
    
    private func makeSUT(
        content: SUT.ContentType = .loading,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (SUT, Model, RouteSpy) {
        
        let model: Model = .mockWithEmptyExcept()
        let sut = SUT(content: content, model: model, closeAction: {})
        let routeSpy = ValueSpy(sut.$route)
    
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model, routeSpy)
    }
}

private enum RouteEquatable: Equatable {
    
    case confirm
    case success
}

private extension PaymentsViewModel.Route {
    
    var routeEquatable: RouteEquatable {
        
        switch self {
        case .confirm: return .confirm
        case .success: return .success
        }
    }
}

private extension Array where Element == PaymentsViewModel.Route? {
    
    var equatable: [RouteEquatable?] {
        
        map(\.?.routeEquatable)
    }
}

private extension ModelAction.Payment.Process.Response {
    
    static let success: Self = .init(result: .complete(.init(status: .success, title: "", titleForActionButton: "")))
    static let confirm: Self = .init(result: .confirm(.emptyWithParameterCode()))
}
