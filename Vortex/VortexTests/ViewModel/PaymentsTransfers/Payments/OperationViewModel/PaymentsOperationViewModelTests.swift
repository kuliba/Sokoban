//
//  PaymentsOperationViewModelTests.swift
//  VortexTests
//
//  Created by Max Gribov on 29.05.2023.
//

import XCTest
@testable import Vortex
import Combine

final class PaymentsOperationViewModelTests: XCTestCase {
    
    func test_initWithEmptyOperation_emptyTopAndFeedSections_continueButtomItemInBottom() throws {
        
        let (sut, _) = makeSut()
        
        // wait for bindings
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(sut.top)
        XCTAssertTrue(sut.feed.isEmpty)
        
        //FIXME: auto creating continue button on view model side should be refacrored. Continue button must be just one of parameters
        let bottomGroups = try XCTUnwrap(sut.bottom)
        let bottomGroupsItems = bottomGroups.flatMap(\.items)
        XCTAssertEqual(bottomGroupsItems.count, 1)
        XCTAssertNotNil(bottomGroupsItems.first as? PaymentsButtonView.ViewModel)
    }
    
    func test_initWithOperationOneStepOneParam_oneFeedGroupWithOneItem() throws {
        
        // given
        let param = makeContinueUpdatableFeedParam(id: "one", value: "test")
        let operation = Payments.Operation.makeWithOneUncompleteStepForAnyService(params: [param])
        let (sut, _) = makeSut(operation: operation)
        
        // wait for bindings
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        let feedGroups = sut.feed
        XCTAssertEqual(feedGroups.count, 1)
        
        let feedItems = feedGroups.flatMap(\.items)
        XCTAssertEqual(feedItems.map(\.id), ["one"])
        XCTAssertEqual(feedItems.map(\.value.current), ["test"])
    }
    
    func test_itemValueChange_itemDidUpdatedActionTriggered() throws {
        
        // given
        let param = makeContinueUpdatableFeedParam(id: "one", value: nil)
        let operation = Payments.Operation.makeWithOneUncompleteStepForAnyService(params: [param])
        let (sut, _) = makeSut(operation: operation)
        let actionsSpy = ValueSpy(sut.action)
        // wait for bindings
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // when
        let firstFeedItem = try XCTUnwrap(sut.feed.first?.items.first)
        firstFeedItem.update(value: "test")
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(actionsSpy.values.count, 1)
        let firstAction = try XCTUnwrap(actionsSpy.values.first as? PaymentsOperationViewModelAction.ItemDidUpdated)
        XCTAssertEqual(firstAction.parameterId, "one")
    }
    
    // first step was processed on back side
    // in case when first step continue updatable item value was upated
    // the operation should be rolled back to the first step
    func test_processedStepCountinueEditableItemValueChange_operationRolledBack() throws {
        
        // given
        let paramOne = makeContinueUpdatableFeedParam(id: "one", value: "test")
        let paramTwo = makeContinueUpdatableFeedParam(id: "two", value: nil)
        let operation = makeWithFirstCompleteSecondUncompleteStepsOperation(first: [paramOne], second: [paramTwo])
        let (sut, _) = makeSut(operation: operation)
        let operationValueSpy = ValueSpy(sut.operation)
        // wait for bindings
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(operationValuesSpyStepsCount(operationValueSpy.values), [2])
        
        // when
        let firstFeedItem = try XCTUnwrap(sut.feed.first?.items.first)
        firstFeedItem.update(value: "tes")
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(operationValuesSpyStepsCount(operationValueSpy.values), [2, 1], "second value must contains one step after operation succesful rollback")
    }
    
    // first step was processed on back side
    // in case when first step continue updatable item value was upated
    // no any action should be sent to model
    func test_processedStepCountinueEditableItemValueChange_modelProcessActionNotTriggered() throws {
        
        // given
        let paramOne = makeContinueUpdatableFeedParam(id: "one", value: "test")
        let paramTwo = makeContinueUpdatableFeedParam(id: "two", value: nil)
        let operation = makeWithFirstCompleteSecondUncompleteStepsOperation(first: [paramOne], second: [paramTwo])
        let (sut, model) = makeSut(operation: operation)
        let modelActionSpy = ValueSpy(model.action)
        // wait for bindings
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // when
        let firstFeedItem = try XCTUnwrap(sut.feed.first?.items.first)
        firstFeedItem.update(value: "tes")
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(modelActionSpy.values.count, 0, "no any model action should be sent, spy values count must be zero")
    }
    
    // first step was processed on back side
    // in case when instant updatable item value was upated
    // ModelAction.Payment.Process.Request should be sent to model
    func test_processedStepInstantUpdatableItemValueChanged_modelProcessActionTriggered() throws {
        
        // given
        let paramOne = makeInstantUpdatableFeedParam(id: "one", value: false)
        let paramTwo = makeContinueUpdatableFeedParam(id: "two", value: nil)
        let operation = makeWithFirstCompleteSecondUncompleteStepsOperation(first: [paramOne], second: [paramTwo])
        let (sut, model) = makeSut(operation: operation)
        let modelActionSpy = ValueSpy(model.action)
        // wait for bindings
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // when
        let firstFeedItem = try XCTUnwrap(sut.feed.first?.items.first)
        firstFeedItem.update(value: "true")
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        let paymentProcessRequestActions = modelActionSpy.values.compactMap { $0 as? ModelAction.Payment.Process.Request }
        XCTAssertEqual(paymentProcessRequestActions.count, 1, "only one Payment.Process.Request action should be sent")
    }
    
    // MARK: - BindModel
    
    func test_modelPaymentProcessResponseWithStepResult_operationUpdated() throws {
        
        let initialOperation = Payments.Operation.makeWithOneUncompleteStepForAnyService(params: [])
        let (sut, model) = makeSut(operation: initialOperation)
        let operationSpy = ValueSpy(sut.operation)
        
        let updatedOperation = Payments.Operation.makeWithOneUncompleteStepForAnyService(params: [
            makeContinueUpdatableFeedParam(id: "test", value: "newValue")
        ])
        
        model.action.send(ModelAction.Payment.Process.Response(result: .step(updatedOperation)))
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        let lastOperation = try XCTUnwrap(operationSpy.values.last)
        XCTAssertEqual(lastOperation.service, updatedOperation.service)
        XCTAssertEqual(lastOperation.steps.count, updatedOperation.steps.count)
    }
}

//MARK: - Helpers

private extension PaymentsOperationViewModelTests {
    
    func makeSut(operation: Payments.Operation = .init(service: .fms), closeAction: @escaping (() -> Void) = {}) -> (sut: PaymentsOperationViewModel, model: Model) {
        
        let model: Model = .emptyMock
        let sut = PaymentsOperationViewModel(operation: operation, model: model, closeAction: closeAction)
        
        return (sut, model)
    }
    
    func makeContinueUpdatableFeedParam(id: Payments.Parameter.ID, value: Payments.Parameter.Value) -> Payments.ParameterMock {
        
        .init(id: id, value: value, placement: .feed)
    }
    
    func makeInstantUpdatableFeedParam(id: Payments.Parameter.ID, value: Bool) -> Payments.ParameterCheck {
        
        let stringValue = value ? "true" : "false"
        
        return .init(.init(id: id, value: stringValue), title: "", urlString: nil)
    }
    
    func makeWithFirstCompleteSecondUncompleteStepsOperation(first: [PaymentsParameterRepresentable], second: [PaymentsParameterRepresentable]) -> Payments.Operation {
        
        Payments.Operation.makeWithFirstCompleteSecondUncompleteStepsForAnyService(first: first, second: second)
    }
    
    func operationValuesSpyStepsCount(_ values: [Payments.Operation]) -> [Int] {
        
        values.map(\.steps).map(\.count)
    }
}

private extension Payments.Operation {
    
    static func makeWithOneUncompleteStepForAnyService(params: [PaymentsParameterRepresentable]) -> Payments.Operation {
        
        let step = Payments.Operation.Step(
            parameters: params,
            front: .init(visible: params.map(\.id), isCompleted: false),
            back: .init(stage: .remote(.start), required: params.map(\.id), processed: nil))
        
        return .init(service: .fms, source: nil, steps: [step], visible: params.map(\.id))
    }
    
    static func makeWithFirstCompleteSecondUncompleteStepsForAnyService(first: [PaymentsParameterRepresentable], second: [PaymentsParameterRepresentable]) -> Payments.Operation {
        
        let firstStep = Payments.Operation.Step(
            parameters: first,
            front: .init(visible: first.map(\.id), isCompleted: true),
            back: .init(stage: .remote(.start), required: first.map(\.id), processed: first.map(\.parameter)))
        
        let secondStep = Payments.Operation.Step(
            parameters: second,
            front: .init(visible: second.map(\.id), isCompleted: true),
            back: .init(stage: .remote(.next), required: second.map(\.id), processed: nil))
        
        return .init(service: .fms, source: nil, steps: [firstStep, secondStep], visible: first.map(\.id) + second.map(\.id))
    }
}
