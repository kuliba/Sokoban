//
//  SimpleTransfersButtonVMFactoryTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.10.2024.
//

protocol TransfersButtonVMFactory {
    
    typealias Button = PTSectionTransfersView.ViewModel.TransfersButtonVM
    typealias ButtonType = PTSectionTransfersView.ViewModel.TransfersButtonType
    
    func makeButton(for _: ButtonType) -> Button
}

struct SimpleTransfersButtonVMFactory {
    
    let action: (ButtonType) -> Void
}

extension SimpleTransfersButtonVMFactory: TransfersButtonVMFactory {
    
    func makeButton(for buttonType: ButtonType) -> Button {
        
        return .init(type: buttonType) { action(buttonType) }
    }
}

@testable import ForaBank
import XCTest

final class SimpleTransfersButtonVMFactoryTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.callCount, 0)
    }
    
    func test_buttonAction_shouldDeliverByPhoneNumberOnByPhoneNumberButtonType() {
        
        let (sut, spy) = makeSUT()
        
        sut.makeButton(for: .byPhoneNumber).action()
        
        XCTAssertNoDiff(spy.payloads, [.byPhoneNumber])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TransfersButtonVMFactory
    private typealias ButtonType = SUT.ButtonType
    private typealias ActionSpy = CallSpy<ButtonType, Void>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ActionSpy
    ) {
        let spy = ActionSpy(stubs: [()])
        let sut: SUT = SimpleTransfersButtonVMFactory(
            action: spy.call(payload:)
        )
        
        return (sut, spy)
    }
}
