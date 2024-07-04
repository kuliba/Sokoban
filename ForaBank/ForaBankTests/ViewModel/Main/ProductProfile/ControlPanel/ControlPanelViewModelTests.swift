//
//  ControlPanelViewModelTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 04.07.2024.
//

@testable import ForaBank
import XCTest
import SwiftUI

final class ControlPanelViewModelTests: XCTestCase {
    
    func test_init_shouldSetButtonsStatusToNilAlertToNil() {
        
        let sut = makeSUT(
            buttons: [
                .init(
                    id: 1,
                    title: "title",
                    icon: .checkImage,
                    event: .blockCard(.cardStub1))
            ],
            makeAlert: { _ in .testAlert},
            makeActions: .emptyActions)
        
        XCTAssertNoDiff(sut.state.buttons.count, 1)
        XCTAssertNoDiff(sut.state.buttons.first?.id, 1)
        XCTAssertNoDiff(sut.state.buttons.first?.title, "title")
        XCTAssertNoDiff(sut.state.buttons.first?.icon, .checkImage)
        XCTAssertNoDiff(sut.state.buttons.first?.event, .blockCard(.cardStub1))
        
        XCTAssertNil(sut.state.status)
        XCTAssertNil(sut.state.alert)
    }

    typealias SUT = ControlPanelViewModel
    typealias MakeAlert = ControlPanelReducer.MakeAlert
    typealias MakeActions = ControlPanelReducer.MakeActions

    private func makeSUT(
        buttons: [ControlPanelButtonDetails] = [],
        makeAlert: @escaping MakeAlert,
        makeActions: MakeActions,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        .init(
            initialState: .init(buttons: buttons),
            reduce: ControlPanelReducer(makeAlert: makeAlert, makeActions: makeActions).reduce(_:_:),
            handleEffect: {_,_  in })
    }
}

extension Alert.ViewModel {
    
    static let testAlert: Self = .init(title: "", message: nil, primary: .init(type: .cancel, title: "", action: {}))
}

extension ControlPanelReducer.MakeActions {
    
    static let emptyActions: Self = .init(
        contactsAction: {},
        blockAction: {},
        unblockAction: {},
        updateProducts: {}
    )
}
