//
//  ProductDetailsReducerTests.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import XCTest
@testable import ProductDetailsUI
import RxViewModel

final class ProductDetailsReducerTests: XCTestCase {
    
    // MARK: - test appear
    
    func test_shouldSetEffectNone() {
        
        assert(.appear, on: .initialState, effect: .none)
    }
    
    func test_shouldUpdateStatusOnAppear() {
        
        assert(.appear, on: .initialState) {
            
            $0.status = .appear
        }
    }
    
    // MARK: - test itemTapped
    
    func test_longPress_shouldSetEffectNone() {
        
        assert(.itemTapped(.longPress("111","text")), on: .initialState, effect: .none)
    }
    
    func test_longPress_shouldUpdateStatusOnItemTap() {
        
        assert(.itemTapped(.longPress("111","text")), on: .initialState) {
            
            $0.status = .itemTapped(.longPress("111","text"))
        }
    }
    
    func test_iconTapNumber_shouldSetEffectNone() {
        
        assert(.itemTapped(.iconTap(.number)), on: .initialState, effect: .none)
    }
    
    func test_iconTapNumber_shouldUpdateStatusNilDetailsStateNeedShowNumber() {
        
        assert(.itemTapped(.iconTap(.number)), on: .initialState) {
            
            $0.status = nil
            $0.detailsState = .needShowNumber
        }
    }
    
    func test_iconTapCVV_shouldSetEffectNone() {
        
        assert(.itemTapped(.iconTap(.cvv)), on: .initialState, effect: .none)
    }
    
    func test_iconTapCVV_shouldUpdateStatusOnItemTap() {
        
        assert(.itemTapped(.iconTap(.cvv)), on: .initialState) {
            
            $0.status = .itemTapped(.iconTap(.cvv))
        }
    }
    
    func test_share_shouldSetEffectNone() {
        
        assert(.itemTapped(.share), on: .initialState, effect: .none)
    }
    
    func test_shareShowCheckBoxFalse_shouldUpdateStatusOnItemTap() {
        
        assert(.itemTapped(.share), on: .init(showCheckBox: false)) {
            
            $0.status = .itemTapped(.share)
        }
    }
    
    func test_shareShowCheckBoxTrue_shouldUpdateStatusNilShowCheckBoxFalse() {
        
        assert(.itemTapped(.share), on: .init(showCheckBox: true)) {
            
            $0.status = nil
            $0.showCheckBox = false
        }
    }
    
    func test_selectCardValueTrue_shouldSetEffectNone() {
        
        assert(.itemTapped(.selectCardValue(true)), on: .initialState, effect: .none)
    }
    
    func test_selectCardValueTrue_shouldUpdateStatusNilUpdateDataForShare() {
        
        assert(.itemTapped(.selectCardValue(true)), on: .initialState) {
            
            $0.status = nil
            $0.dataForShare = .cardsCopyValue
        }
    }
    
    func test_selectCardValueFalse_shouldSetEffectNone() {
        
        assert(.itemTapped(.selectCardValue(false)), on: .initialState, effect: .none)
    }
    
    func test_selectCardValueFalse_shouldUpdateStatusNilUpdateDataForShare() {
        
        assert(.itemTapped(.selectCardValue(false)), on: .init(dataForShare: .cardsCopyValue)) {
            
            $0.status = nil
            $0.dataForShare = []
        }
    }
    
    func test_selectAccountValueTrue_shouldSetEffectNone() {
        
        assert(.itemTapped(.selectAccountValue(true)), on: .initialState, effect: .none)
    }
    
    func test_selectAccountValueTrue_shouldUpdateStatusNilUpdateDataForShare() {
        
        assert(.itemTapped(.selectAccountValue(true)), on: .initialState) {
            
            $0.status = nil
            $0.dataForShare = .accountCopyValue
        }
    }
    
    func test_selectAccountValueFalse_shouldSetEffectNone() {
        
        assert(.itemTapped(.selectAccountValue(false)), on: .initialState, effect: .none)
    }
    
    func test_selectAccountValueFalse_shouldUpdateStatusNilUpdateDataForShare() {
        
        assert(.itemTapped(.selectAccountValue(false)), on: .init(dataForShare: .accountCopyValue)) {
            
            $0.status = nil
            $0.dataForShare = []
        }
    }
    
    // MARK: - test sendAll
    
    func test_sendAll_shouldSetEffectNone() {
        
        assert(.sendAll, on: .initialState, effect: .none)
    }
    
    func test_sendAll_shouldUpdateStatusOnSendAll() {
        
        assert(.sendAll, on: .initialState) {
            
            $0.status = .sendAll
        }
    }
    
    // MARK: - test sendSelect
    
    func test_sendSelect_shouldSetEffectNone() {
        
        assert(.sendSelect, on: .initialState, effect: .none)
    }
    
    func test_sendSelect_shouldUpdateStatusOnSendSelectUpdateShowChekboxUpdateTitle() {
        
        assert(.sendSelect, on: .init(showCheckBox: false)) {
            
            $0.status = .sendSelect
            $0.showCheckBox = true
            $0.title = "Выберите реквизиты"
        }
    }
    
    // MARK: - test hideCheckBox
    
    func test_hideCheckbox_shouldSetEffectNone() {
        
        assert(.hideCheckbox, on: .initialState, effect: .none)
    }
    
    func test_hideCheckbox_shouldUpdateStatusNilUpdateShowChekboxUpdateTitle() {
        
        assert(.hideCheckbox, on: .init(showCheckBox: true, title: "Выберите реквизиты")) {
            
            $0.status = nil
            $0.showCheckBox = false
            $0.title = "Реквизиты счета и карты"
        }
    }
    
    // MARK: - test close
    
    func test_close_shouldSetEffectNone() {
        
        assert(.close, on: .initialState, effect: .none)
    }
    
    func test_close_shouldUpdateStatusOnClose() {
        
        assert(.close, on: .initialState) {
            
            $0.status = .close
        }
    }
    
    // MARK: - test close
    
    func test_closeModal_shouldSetEffectNone() {
        
        assert(.closeModal, on: .initialState, effect: .none)
    }
    
    func test_closeModal_shouldUpdateStatusOnCloseModal() {
        
        assert(.closeModal, on: .initialState) {
            
            $0.status = .closeModal
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ProductDetailsReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias Result = (State, Effect?)
    
    private func makeSUT(
        shareAction: @escaping SUT.ShareAction = {_ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(shareInfo: shareAction)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
    
    private func reduce(
        _ sut: SUT,
        _ state: State = .initialState,
        event: Event
    ) -> (state: State, effect: Effect?) {
        
        return sut.reduce(state, event)
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let receivedEffect: Effect? = reduce(sut ?? makeSUT(), state, event: event).1
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)) state, but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        _assertState(
            sut,
            event,
            on: state,
            updateStateToExpected: updateStateToExpected,
            file: file, line: line
        )
    }
}

extension ProductDetailsReducer: Reducer { }

private extension Array where Element == String {
    
    static let cardsCopyValue: Self = [
        "Держатель: Константин Войцехов",
        "Номер карты: 4897 2525 1111 7654",
        "Карта действует до: 01/01"
    ]
    
    static let accountCopyValue: Self = [
        "Получатель: Получатель Константин Войцехов",
        "Номер счета: 408178810888 005001137",
        "БИК: 044525341",
        "Кореспондентский счет: 301018103000000000341",
         """
         ИНН: 7704113772
         КПП: 770401001
         """
    ]
}

private extension ProductDetailsState {
    
    init(
        status: ProductDetailsStatus? = nil,
        showCheckBox: Bool = false,
        title: String = "Реквизиты счета и карты",
        detailsState: DetailsState = .initial,
        dataForShare: [String] = []
    ) {
        self.init(
            accountDetails: .accountItems,
            cardDetails: .cardItems,
            status: status,
            showCheckBox: showCheckBox,
            title: title,
            detailsState: detailsState,
            dataForShare: dataForShare
        )
    }
}
