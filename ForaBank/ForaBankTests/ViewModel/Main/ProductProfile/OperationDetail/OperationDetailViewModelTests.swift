//
//  OperationDetailViewModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 22.06.2023.
//

import XCTest
@testable import ForaBank

final class OperationDetailViewModelTests: XCTestCase {
    
    func test_modelAction_templateComplete_shouldCreateDocumentWithTemplateID() throws {
        
        let (sut, spy) = try makeSUT()
        let templateId = 1
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [])
        XCTAssertNotNil(sut)
        
        XCTAssertNoDiff(spy.values, [])
        
        sut.model.action.send(
            ModelAction.PaymentTemplate.Save.Complete(
                paymentTemplateId: templateId
            )
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [.documentId(1)])
    }
    
    func test_modelAction_templateDeleteComplete_shouldCreateDocumentWithTemplateID() throws {
        
        let (sut, spy) = try makeSUT()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [])
        XCTAssertNotNil(sut)
        
        sut.model.action.send(
            ModelAction.PaymentTemplate.Delete.Complete(paymentTemplateIdList: [])
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNoDiff(spy.values, [.documentId(1)])
    }
    
    func test_modelAction_detailResponseSuccess_shouldSetIsLoadingToFalse() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.isLoading = true
        XCTAssertTrue(sut.isLoading)
        
        sut.model.action.send(
            ModelAction.Operation.Detail.Response(result:
                    .success(.stub())
            )
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_modelAction_detailResponseFailure_shouldSetIsLoadingToFalse() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.isLoading = true
        XCTAssertTrue(sut.isLoading)
        
        sut.model.action.send(
            ModelAction.Operation.Detail.Response(result:
                    .failure(ModelError.unauthorizedCommandAttempt)
            )
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_action_closeFullScreenSheet_shouldSetFullScreenSheetToNil() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.fullScreenSheet = .init(type: .payments(.sample))
        XCTAssertNotNil(sut.fullScreenSheet)
        
        sut.action.send(
            OperationDetailViewModelAction.CloseFullScreenSheet()
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNil(sut.fullScreenSheet)
    }
    
    func test_action_closeSheet_shouldSetFullScreenSheetToNil() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.sheet = .init(kind: .info(.detailMockData()))
        XCTAssertNotNil(sut.sheet)
        
        sut.action.send(
            OperationDetailViewModelAction.CloseSheet()
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertNil(sut.sheet)
    }
    
    func test_action_showDocument_shouldCreateSheetWithSample() throws {
        
        let (sut, _) = try makeSUT()
        XCTAssertNil(sut.sheet)
        
        sut.action.send(
            OperationDetailViewModelAction.ShowDocument(viewModel: .sample)
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNotNil(sut.sheet)
        
        let sheet = try XCTUnwrap(sut.sheet)
        XCTAssertNoDiff(
            sheet.type,
            .printForm(
                state: .document(
                    title: "Сохранить или отправить",
                    button: .red
                )))
    }
    
    func test_action_showInfo_shouldCreateSheetWithMockData() throws {
        
        let (sut, _) = try makeSUT()
        XCTAssertNil(sut.sheet)
        
        sut.action.send(
            OperationDetailViewModelAction.ShowInfo(viewModel: .detailMockData())
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        XCTAssertNotNil(sut.sheet)
        
        let sheet = try XCTUnwrap(sut.sheet)
        XCTAssertNoDiff(sheet.type, .detailInfo([String].titles.map(InfoCell.init)))
    }
    
    // MARK: Helpers
    
    private typealias InfoCell = OperationDetailViewModel.Sheet.Cell
}

extension OperationDetailViewModelTests {
    
    typealias Kind = ModelAction.Operation.Detail.Request.Kind
    
    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (OperationDetailViewModel, ValueSpy<Kind>) {
        
        let model = Model.mockWithEmptyExcept()
        model.statements.value = [1: .init(
            period: .init(start: Date(), end: Date()),
            statements: [.stub()])
        ]
        
        let sut = try XCTUnwrap(
            OperationDetailViewModel(
                productStatement: .stub(),
                product: .stub(),
                model: model
            ),
            "failed to create OperationDetailViewModel",
            file: file, line: line
        )
        
        let publisher = sut.model.action
            .compactMap { $0 as? ModelAction.Operation.Detail.Request }
            .map(\.type)
        
        let spy = ValueSpy(publisher)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
}
private extension PrintFormView.ViewModel.State {
    
    var `case`: Case {
        
        switch self {
        case let .document(_, button):
            return .document(title: button.title, button: button.style)
        case .failed: return .failed
        case .loading: return .loading
        }
    }
    
    enum Case: Equatable {
        
        case document(
            title: String,
            button: ButtonSimpleView.ViewModel.ButtonStyle
        )
        case loading
        case failed
    }
}

private extension OperationDetailViewModel.Sheet {
    
    var type: `Type` {
        
        switch self.kind {
        case let .info(viewModel):
            return .detailInfo(viewModel.cells.map(\.title).map(Cell.init))
            
        case let .printForm(viewModel):
            return .printForm(state: viewModel.state.case)
        }
    }
    
    enum `Type`: Equatable {
        
        case printForm(state: PrintFormView.ViewModel.State.Case)
        case detailInfo([Cell])
    }
    
    struct Cell: Equatable {
        
        let title: String
    }
}

private extension UUID {
    
    static let test: Self = .init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!
}

private extension Array where Element == String {
    
    static let titles: Self = [
        
        "По номеру телефона",
        "Получатель",
        "Банк получателя",
        "Сумма перевода",
        "Комиссия",
        "Счет списания",
        "Назначение платежа",
        "Номер операции СБП",
        "Дата и время операции (МСК)",
    ]
}
