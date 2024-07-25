//
//  ListHorizontalRectangleImageViewModelTests.swift
//
//
//  Created by Andryusina Nataly on 11.07.2024.
//

@testable import LandingUIComponent
import XCTest

final class ListHorizontalRectangleImageViewModelTests: XCTestCase {
    
    //MARK: - test itemAction
    
    func test_itemAction_detailsNotNilCanOpenTrue_shouldCallSelectDetail() {
                
        assertItemAction(
            for: createItem(detail: .init(groupId: "1", viewId: "2")),
            canOpenDetail: { _ in return true },
            [.selectDetail])
    }
    
    func test_itemAction_detailsNotNilCanOpenFalseBannerAction_shouldCallBannerAction() {
                
        assertItemAction(
            for: createItem(detail: .init(groupId: "DEPOSIT_OPEN", viewId: "2")),
            canOpenDetail: { _ in return false },
            [.bannerAction])
    }
    
    func test_itemAction_detailsNotNilCanOpenFalseNotBannerActionLinkNotEmpty_shouldCallLink() {
                
        assertItemAction(
            for: createItem(detail: .init(groupId: "2", viewId: "2"), link: "link"),
            canOpenDetail: { _ in return false },
            [.openLink])
    }
    
    func test_itemAction_detailsNotNilCanOpenFalseNotBannerActionLinkEmpty_shouldCallNothing() {
                
        assertItemAction(
            for: createItem(detail: .init(groupId: "2", viewId: "2"), link: ""),
            canOpenDetail: { _ in return false },
            [])
    }

    func test_itemAction_detailsNilLinkNotNil_shouldCallLink() {
                
        assertItemAction(
            for: createItem(link: "link"),
            canOpenDetail: { _ in return false },
            [.openLink])
    }

    // MARK: - Helpers
   
    private typealias Item = UILanding.List.HorizontalRectangleImage.Item
    private typealias ViewModel = ListHorizontalRectangleImageView.ViewModel
    
    private func createItem(
        imageLink: String = "",
        detail: Item.Detail? = nil,
        link: String = ""
    ) -> Item {
        
        .init(
            imageLink: imageLink,
            link: link,
            detail: detail)
    }

    private func assertItemAction(
        for item: Item,
        canOpenDetail: UILanding.CanOpenDetail,
        _ expectedActionTypes: [ActionType]
    ) {
        
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
                case .sticker:
                    received.append(.sticker)

                case .bannerAction:
                    received.append(.bannerAction)
                    
                case .listVerticalRoundImageAction:
                    received.append(.listVerticalRoundImageAction)
                }
            }, 
            canOpenDetail: canOpenDetail
        )
        
        XCTAssertEqual(received, expectedActionTypes)
    }

    enum ActionType {
        
        case goMain
        case openLink
        case orderCard
        case selectDetail
        case sticker
        case bannerAction
        case listVerticalRoundImageAction
    }

}
