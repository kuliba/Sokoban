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
    
    func test_buttonAction_shouldDeliverButtonType() {
        
        for type in SUT.ButtonType.allCases {
            
            tap(on: type, delivers: type)
        }
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
        let spy = ActionSpy(stubs: .init(repeating: (), count: 5))
        let sut: SUT = SimpleTransfersButtonVMFactory(
            action: spy.call(payload:)
        )
        
        return (sut, spy)
    }
    
    // MARK: - DSL
    
    private func tap(
        on buttonType: ButtonType,
        delivers expectedButtonType: ButtonType,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (sut, spy) = makeSUT()
        sut.makeButton(for: buttonType).action()
        XCTAssertNoDiff(spy.payloads, [expectedButtonType], file: file, line: line)
    }
}
