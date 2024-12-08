//
//  PaymentsSuccessViewModelTests.swift
//  VortexTests
//
//  Created by Max Gribov on 19.06.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsSuccessViewModelTests: XCTestCase {
    
    func test_init_withEmptySections_emptyFeed_emptyBottom() {
        
        let (sut, _, _, _) = makeSUT()
        
        XCTAssertTrue(sut.feed.isEmpty)
        XCTAssertTrue(sut.bottom.isEmpty)
    }
    
    func test_init_withSections_feedAndBottomItems_correct() {
        
        let sections = [makeSection(.feed, ["one"]), makeSection(.bottom, ["two"])]
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.07)
        let (sut, _, _, _) = makeSUT(with: sections)
        
        XCTAssertEqual(sut.feed.flatMap(\.items).map(\.source.id), ["one"])
        XCTAssertEqual(sut.bottom.flatMap(\.items).map(\.source.id), ["two"])
    }
    
    func test_sectionActionMainButtonDidTapped_sutAction_buttonClose() throws {
        
        let section = makeSection(.feed, ["one", "two", "three"])
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        let (sut, _, scheduler, _) = makeSUT(with: [section])
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        let sutActionSpy = ValueSpy(sut.action)
        
        section.action.send(PaymentsSectionViewModelAction.Button.DidTapped(action: .main))
        scheduler.advance()
        
        XCTAssertNotNil(sutActionSpy.values.first as? PaymentsSuccessAction.Button.Close)
    }
    
    func test_sectionActionSaveButtonDidTapped_modelActionPaymentSubscribtionRequest_withAllParameters() throws {
        
        let section = makeSection(.feed, ["one", "two", "three"])
        let (sut, model, scheduler, _) = makeSUT(with: [section])
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        let modelActionSpy = ValueSpy(model.action)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.07)
        
        section.action.send(PaymentsSectionViewModelAction.Button.DidTapped(action: .save))
        scheduler.advance()
        
        let action = try XCTUnwrap(modelActionSpy.values.first as? ModelAction.Payment.Subscription.Request)
        XCTAssertEqual(action.parameters.map(\.id), sut.parameters.map(\.id))
        XCTAssertEqual(action.action, .link)
        XCTAssertNotNil(sut.spinner)
    }
    
    func test_sectionActionCancelButtonDidTapped_modelActionPaymentSubscribtionRequest_withAllParameters() throws {
        
        let section = makeSection(.feed, ["one", "two", "three"])
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        let (sut, model, scheduler, _) = makeSUT(with: [section])
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        let modelActionSpy = ValueSpy(model.action)
        
        section.action.send(PaymentsSectionViewModelAction.Button.DidTapped(action: .cancel))
        scheduler.advance()
        
        let action = try XCTUnwrap(modelActionSpy.values.first as? ModelAction.Payment.Subscription.Request)
        XCTAssertEqual(action.parameters.map(\.id), sut.parameters.map(\.id))
        XCTAssertEqual(action.action, .deny)
        XCTAssertNotNil(sut.spinner)
    }
    
    func test_modelActionPaymentSubscribtionResponseSuccess_successViewModelPresented() {
        
        let (sut, model, scheduler, _) = makeSUT()
        
        model.action.send(ModelAction.Payment.Subscription.Response(result: .success(Payments.Success(
            operation: nil,
            parameters: []
        ))))
        scheduler.advance()
        
        XCTAssertNotNil(sut.fullScreenCover)
        XCTAssertNil(sut.spinner)
    }
    
    func test_modelActionPaymentSubscribtionResponseFailure_alertPresented() {
        
        let (sut, model, scheduler, _) = makeSUT()
        
        model.action.send(ModelAction.Payment.Subscription.Response(result: .failure(NSError(domain: "", code: 0))))
        scheduler.advance()
        
        XCTAssertNotNil(sut.alert)
        XCTAssertNil(sut.spinner)
    }
    
    func test_initWithPaymentOperationDetailIDParam_adapterRequestOperationDetailMethodCalledOnce() {
        
        let operationDetailParam = makeAnyParameter(withIdentifier: .successOperationDetailID, value: "100")
        let section = makeSection(.feed, [operationDetailParam])
        let (sut, _, _, adapter) = makeSUT(with: [section])
        
        XCTAssertEqual(sut.paymentOperationDetailID, 100)
        XCTAssertEqual(adapter.requestOperationDetailCalls, [100])
    }
}

//MARK: - SUT with Payments.Success tests

extension PaymentsSuccessViewModelTests {
    
    func test_initWithSuccess_correctParameters() {
        
        let success = makeSuccess()
        let sut = makeSUT(with: success)
        
        XCTAssertEqual(sut.parameters.map(\.id),
                       ["ru.vortex.sense.success.mode",
                        "ru.vortex.sense.success.status",
                        "ru.vortex.sense.success.title",
                        "ru.vortex.sense.success.optionButtons",
                        "ru.vortex.sense.success.actionButton"])
    }
    
    func test_initWithSuccessModeNormalParam_normalMode() {
        
        let success = makeSuccess(mode: .normal)
        let sut = makeSUT(with: success)
        
        XCTAssertEqual(sut.mode, .normal)
    }
    
    func test_initWithSuccessStatusComplete_paramStatusSuccess() throws {
        
        let success = makeSuccess(status: .complete)
        let sut = makeSUT(with: success)
        
        XCTAssertEqual(sut.documentStatus, .complete)
    }
    
    func test_initWithSuccessModeOperationDetailIdNil_nilOperationDetailId() {
        
        let success = makeSuccess(paymentOperationDetailId: nil)
        let sut = makeSUT(with: success)
        
        XCTAssertNil(sut.paymentOperationDetailID)
    }
    
    func test_initWithSuccessModeOperationDetailIdValue_valueOperationDetailId() {
        
        let success = makeSuccess(paymentOperationDetailId: 100)
        let sut = makeSUT(with: success)
        
        XCTAssertEqual(sut.paymentOperationDetailID, 100)
    }
}

//MARK: - Helpers

private extension PaymentsSuccessViewModelTests {
    
    func makeSUT(
        with sections: [PaymentsSectionViewModel] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsSuccessViewModel,
        model: Model,
        scheduler: TestSchedulerOfDispatchQueue,
        adapter: PaymentsSuccessViewModelAdapterSpy
    ) {
        let scheduler = DispatchQueue.test
        let model: Model = .mockWithEmptyExcept()
        let adapter = PaymentsSuccessViewModelAdapterSpy(model: model, scheduler: scheduler.eraseToAnyScheduler())
        let sut = PaymentsSuccessViewModel(
            sections: sections,
            adapter: adapter,
            operation: nil,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        // TODO: restore memory leak tracking for model
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model, scheduler, adapter)
    }
    
    func makeSUT(
        with success: Payments.Success,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PaymentsSuccessViewModel {
        
        let scheduler = DispatchQueue.test
        let model: Model = .mockWithEmptyExcept()
        let sut = PaymentsSuccessViewModel(paymentSuccess: success, model, scheduler: scheduler.eraseToAnyScheduler())
        
        // TODO: restore memory leak tracking for model
        // trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func makeSection(
        _ placement: Payments.Parameter.Placement,
        _ parametersIDs: [Payments.Parameter.ID]
    ) -> PaymentsSectionViewModel {
        
        let items = parametersIDs
            .map { makeAnyParameter(id: $0) }
            .map { makeAnyItem(source: $0) }
        
        return .init(
            placement: placement,
            groups: [makeGroup(items: items)])
    }
    
    func makeSection(
        _ placement: Payments.Parameter.Placement,
        _ parameters: [PaymentsParameterRepresentable]
    ) -> PaymentsSectionViewModel {
        
        let items = parameters
            .map { makeAnyItem(source: $0) }
        
        return .init(
            placement: placement,
            groups: [makeGroup(items: items)])
    }
    
    func makeGroup(id: String = UUID().uuidString, items: [PaymentsParameterViewModel]) -> PaymentsGroupViewModel {
        
        .init(id: id, items: items)
    }
    
    func makeAnyItem(source: PaymentsParameterRepresentable) -> PaymentsParameterViewModel {
        
        .init(source: source)
    }
    
    func makeAnyParameter(
        id: Payments.Parameter.ID = UUID().uuidString,
        value: Payments.Parameter.Value = nil,
        placement: Payments.Parameter.Placement = .feed,
        group: Payments.Parameter.Group? = nil
    ) -> PaymentsParameterRepresentable {
        
        Payments.ParameterMock(
            id: id,
            value: value,
            placement: placement,
            group: group)
    }
    
    func makeAnyParameter(
        withIdentifier identifier: Payments.Parameter.Identifier,
        value: Payments.Parameter.Value = nil,
        placement: Payments.Parameter.Placement = .feed,
        group: Payments.Parameter.Group? = nil
    ) -> PaymentsParameterRepresentable {
        
        Payments.ParameterMock(
            id: identifier.rawValue,
            value: value,
            placement: placement,
            group: group)
    }
    
    func makeSuccess(
        mode: PaymentsSuccessViewModel.Mode = .normal,
        paymentOperationDetailId: Int? = nil,
        status: TransferResponseBaseData.DocumentStatus = .complete,
        amount: String? = nil
    ) -> Payments.Success {
        
        .init(
            model: .mockWithEmptyExcept(),
            mode: mode,
            paymentOperationDetailId: paymentOperationDetailId,
            documentStatus: status,
            amount: amount)
    }
}

class PaymentsSuccessViewModelAdapterSpy: PaymentsSuccessViewModelAdapter {
    
    var requestOperationDetailCalls = [Int]()
    
    override func requestOperationDetail(with paymentOperationDetailID: Int) {
        
        requestOperationDetailCalls.append(paymentOperationDetailID)
    }
}
