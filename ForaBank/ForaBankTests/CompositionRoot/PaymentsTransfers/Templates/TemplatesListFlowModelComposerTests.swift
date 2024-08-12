//
//  TemplatesListFlowModelComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.08.2024.
//

@testable import ForaBank
import XCTest

final class TemplatesListFlowModelComposerTests: XCTestCase {
    
    func test_compose_shouldSetTemplatesDismissAction() throws {
        
        let sut = makeSUT(flag: .inactive)
        let exp = expectation(description: "wait for dismiss action")
        let flowModel = sut.compose { exp.fulfill() }
        
        try flowModel.dismissContent()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldSetTemplatesNavBarBackAction() throws {
        
        let sut = makeSUT(flag: .inactive)
        let exp = expectation(description: "wait for dismiss action")
        let flowModel = sut.compose { exp.fulfill() }
        
        try flowModel.dismissContentViaNavBarBackButton()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_compose_shouldDeliverLegacyForInactiveFlag() throws {
        
        let sut = makeSUT(flag: .inactive)
        let flowModel = sut.compose {}
        
        flowModel.select(makeTemplate())
        
        assertLegacyDestination(flowModel)
    }
    
    // MARK: - Helpers
    
    private typealias Flag = UtilitiesPaymentsFlag
    private typealias SUT = TemplatesListFlowModelComposer
    private typealias FlowModel = TemplatesListFlowModel<TemplatesListViewModel>
    
    private func makeSUT(
        flag: Flag.RawValue,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let model: Model = .emptyMock
        let sut = SUT(
            model: model,
            utilitiesPaymentsFlag: .init(flag),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeTemplate(
        id: Int = .random(in: 1...100),
        type: PaymentTemplateData.Kind = .sfp
    ) -> PaymentTemplateData {
        
        return .templateStub(paymentTemplateId: id, type: type)
    }
    
    private func assertLegacyDestination(
        _ flowModel: FlowModel,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch flowModel.state.status {
        case .destination(.payment(.legacy)):
            break
            
        default:
            XCTFail("Expected to have legacy destination but got \(String(describing: flowModel.state.status)) instead.")
        }
    }
}

// MARK: - DSL

private extension TemplatesListFlowModel
where Content == TemplatesListViewModel {
    
    func select(_ template: PaymentTemplateData) {
        
        let action = TemplatesListViewModelAction.OpenDefaultTemplate(template: template)
        state.content.action.send(action)
    }
    
    func dismissContent(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        state.content.dismissAction()
    }
    
    func dismissContentViaNavBarBackButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {

        let navBar = try XCTUnwrap(state.content.navBarState.regularModel, "Expected to have regular nav bar", file: file, line: line)
        navBar.backButton.action()
    }
//    
//    func dismissLegacy(
//        file: StaticString = #file,
//        line: UInt = #line
//    ) throws {
//
//        let legacy = try XCTUnwrap(state.content)
//    }
}
