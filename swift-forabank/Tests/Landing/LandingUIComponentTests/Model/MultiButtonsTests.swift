//
//  MultiButtonsTests.swift
//  
//
//  Created by Andryusina Nataly on 22.09.2023.
//

import XCTest
@testable import LandingUIComponent

final class MultiButtonsTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let action: Action = .init(type: "do")
        let sut = makeSUT(
            items: [
                .init(
                    text: "text",
                    style: "style",
                    detail: .init(groupId: "1", viewId: "2"),
                    link: "link",
                    action: action)
            ],
            selectDetail: { _ in },
            action: { _ in }
        )
        
        XCTAssertEqual(sut.data.list.count, 1)
        XCTAssertEqual(sut.data.list.first?.link, "link")
        XCTAssertEqual(sut.data.list.first?.text, "text")
        XCTAssertEqual(sut.data.list.first?.detail?.groupId, "1")
        XCTAssertEqual(sut.data.list.first?.detail?.viewId, "2")
        XCTAssertEqual(sut.data.list.first?.action, action)
    }
   
    //MARK: - test imageRequests

    func test_imageRequests_shouldReturnEmpty() {
        
        let sut = makeSUT()
        
        let result = sut.data.imageRequests()
        
        XCTAssertTrue(result.isEmpty)
    }
    
    //MARK: - test itemAction
    
    func test_itemAction_shouldCallOpenLink() {
        
        var startValue: ActionType = .initinalValue
        let item = createItem(link: "aaa")
        
        let sut = makeSUT(
            items: [item],
            selectDetail: { _ in startValue = .selectDetail },
            action: {_ in }
        )
        
        sut.itemAction(item: item)
        
        XCTAssertEqual(startValue, .initinalValue)
    }
    
    func test_itemAction_actionIsGoToMain_shouldCallGoMain() {
        
        assertItemAction(
            for: createItem(action: .init(.init("goToMain"))),
            [.goMain])
    }
    
    func test_itemAction_actionNilDetailsNotNil_shouldCallDetails() {
        
        assertItemAction(
            for: createItem(
                detail: .init(groupId: "1", viewId: "2"),
                action: nil),
            [.selectDetail])
    }
    
    func test_itemAction_actionNilDetailsNilLinkNotNil_shouldCallLink() {
                
        assertItemAction(for: createItem(link: "link"), [.openLink])
    }
    
    func test_itemAction_actionNotGoToMainDetailsNilLinkNil_shouldCallNothing() {

        assertItemAction(for: createItem(
            detail: nil,
            link: nil,
            action: .init(.init("go"))), [])
    }
    
    // MARK: - Helpers
    
    typealias ViewModel = MultiButtonsView.ViewModel
    typealias Item = UILanding.Multi.Buttons.Item
    typealias Action = UILanding.Multi.Buttons.Item.Action
    
    private func createItem(
        text: String = "1",
        style: String = "",
        detail: Item.Detail? = nil,
        link: String? = nil,
        action: String? = nil
    ) -> Item {
        
        .init(
            text: text,
            style: style,
            detail: detail,
            link: link,
            action: action.map { .init(type: .init(rawValue: $0)) }
        )
    }
    
    func assertItemAction(for item: Item, _ expectedActionTypes: [ActionType]) {
        
        var received = [ActionType]()
        
        ViewModel.itemAction(
            item: item,
            selectDetail: { _ in received.append(.selectDetail) },
            action: {
                switch $0 {
                case let .card(card):
                    switch card {
                        
                    case .goToMain:
                        received.append(.goMain)
                    case .order:
                        received.append(.orderCard)
                    case .openUrl:
                        received.append(.openLink)
                    }
                case .sticker(_):
                    break
                }
            }
        )
        
        XCTAssertEqual(received, expectedActionTypes)
    }

    private func makeSUT(
        items: [Item] = [.default],
        selectDetail: @escaping SelectDetail = { _ in },
        action: @escaping (LandingEvent) -> Void = { _ in }
    ) -> MultiButtonsView.ViewModel {
        
        return .init(
            data: .init(list: items),
            selectDetail: selectDetail,
            action: action)
    }
    
    enum ActionType {
        
        case initinalValue
        case goMain
        case openLink
        case orderCard
        case selectDetail
        case orderSticker
    }
}

private extension UILanding.Multi.Buttons.Item {
    
    static let `default`: Self = .init(
        text: "text",
        style: "style",
        detail: .init(groupId: "1", viewId: "2"),
        link: "link",
        action: .init(type: "do"))
}
