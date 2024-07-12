//
//  ControlPanelViewModelTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 04.07.2024.
//

@testable import ForaBank
import XCTest
import SwiftUI
import Combine

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
    typealias MakeViewModels = ControlPanelReducer.MakeViewModels

    private func makeSUT(
        buttons: [ControlPanelButtonDetails] = [],
        navigationBarViewModel: NavigationBarView.ViewModel = .sample,
        makeAlert: @escaping MakeAlert,
        makeActions: MakeActions,
        makeViewModels: MakeViewModels = .emptyViewModels,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        .init(
            initialState: .init(buttons: buttons, navigationBarViewModel: navigationBarViewModel),
            reduce: ControlPanelReducer(
                makeAlert: makeAlert,
                makeActions: makeActions,
                makeViewModels: makeViewModels
            ).reduce(_:_:),
            handleEffect: {_,_  in })
    }
}

extension Alert.ViewModel {
    
    static let testAlert: Self = .init(title: "", message: nil, primary: .init(type: .cancel, title: "", action: {}))
}

extension ControlPanelReducer.MakeActions {
    
    static let emptyActions: Self = .init(
        blockAction: {},
        changePin: {_ in },
        contactsAction: {},
        unblockAction: {}, 
        updateProducts: {}
    )
}

extension ControlPanelReducer.MakeViewModels {
    
    static let emptyViewModels: Self = .init(
        stickerLanding: .init(
            initialState: .success(.preview),
            imagePublisher: .imagePublisher,
            imageLoader: {_ in }, 
            makeIconView:  { _ in .init(
            image: .cardPlaceholder,
            publisher: Just(.cardPlaceholder).eraseToAnyPublisher()
        )},
            config: .stickerDefault,
            landingActions: {_ in })
    )
}
