//
//  ListVerticalRoundImageViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2023.
//

import XCTest
@testable import LandingUIComponent
import SwiftUI

final class ListVerticalRoundImageViewModelTests: XCTestCase {

    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT(
            title: "title",
            displayedCount: 1,
            dropButtonOpenTitle: "2",
            dropButtonCloseTitle: "3",
            items: [.init(
                md5hash: "4",
                title: "5",
                subInfo: "6",
                link: "7",
                appStore: "8",
                googlePlay: "9",
                detail: .init(groupId: "10", viewId: "11"), 
                action: .init(type: "actionType"))],
            images: ["1":.bolt],
            selectDetail:  { _ in }
        )
        
        XCTAssertEqual(sut.data.title, "title")
        XCTAssertEqual(sut.data.displayedCount, 1)
        XCTAssertEqual(sut.data.dropButtonOpenTitle, "2")
        XCTAssertEqual(sut.data.dropButtonCloseTitle, "3")

        XCTAssertEqual(sut.data.list.count, 1)
        XCTAssertEqual(sut.data.list.first?.md5hash, "4")
        XCTAssertEqual(sut.data.list.first?.title, "5")
        XCTAssertEqual(sut.data.list.first?.subInfo, "6")
        XCTAssertEqual(sut.data.list.first?.link, "7")
        XCTAssertEqual(sut.data.list.first?.appStore, "8")
        XCTAssertEqual(sut.data.list.first?.googlePlay, "9")
        XCTAssertEqual(sut.data.list.first?.detail?.groupId, "10")
        XCTAssertEqual(sut.data.list.first?.detail?.viewId, "11")
        XCTAssertEqual(sut.data.list.first?.action?.type, "actionType")

        XCTAssertEqual(sut.images.count, 1)
        XCTAssertEqual(sut.images.first?.key, "1")
        XCTAssertEqual(sut.images.first?.value, .bolt)
    }
   
    //MARK: - test imageRequests

    func test_imageRequests_shouldReturnEmpty() {
        
        let sut = makeSUT()
        
        let result = sut.data.imageRequests()
        
        XCTAssertEqual(result.count, 1)
    }
    
    //MARK: - test itemAction
    
    func test_itemAction_shouldNotCallSelectDetail() {
        
        var startValue: ActionType = .initinalValue
        let item = createItem(link: "aaa")
        
        let sut = makeSUT(
            items: [item],
            selectDetail: { _ in startValue = .selectDetail }
        )
        
        sut.action(for: item)
        
        XCTAssertEqual(startValue, .initinalValue)
    }
    
    func test_itemAction_detailsNotNilCanOpenTrue_shouldCallDetails() {
        
        var startValue: ActionType = .initinalValue
        
        ViewModel.action(
            item: createItem(detail: .init(groupId: "1", viewId: "2")),
            selectDetail: { _ in startValue = .selectDetail }, 
            action: { _ in },
            canOpenDetail: { _ in true }
        )
        
        XCTAssertEqual(startValue, .selectDetail)
    }
    
    func test_itemAction_detailsNotNilCanOpenFalse_shouldCallNothing() {
        
        var startValue: ActionType = .initinalValue
        
        ViewModel.action(
            item: createItem(detail: .init(groupId: "1", viewId: "2")),
            selectDetail: { _ in startValue = .selectDetail },
            action: { _ in },
            canOpenDetail: { _ in false }
        )
        
        XCTAssertEqual(startValue, .initinalValue)
    }
    
    func test_itemAction_detailsNilLinkNotNil_shouldCallLink() {
        
        var startValue: ActionType = .initinalValue
        
        ViewModel.action(
            item: createItem(link: "aaa"),
            selectDetail: { _ in startValue = .selectDetail },
            action: { _ in },
            canOpenDetail: { _ in false }
        )
        
        XCTAssertEqual(startValue, .initinalValue)
    }
    
    // MARK: - test disableAction
    
    func test_disableAction_allLinksilDetailsNil_shouldSetDisableActionTrue() {
        
        let item = createItem(
            link: nil,
            appStore: nil,
            googlePlay: nil,
            detail: nil)
        
        XCTAssertTrue(item.disableAction)        
    }
            
    func test_disableAction_linkNotNilDetailsNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: "1",
            appStore: nil,
            googlePlay: nil,
            detail: nil)
        
        XCTAssertFalse(item.disableAction)
    }
    
    func test_disableAction_linkNotNilAppStoreNotNilGooglePlayNilDetailsNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: "1",
            appStore: "appStore",
            googlePlay: nil,
            detail: nil)
        
        XCTAssertFalse(item.disableAction)
    }
    
    func test_disableAction_linkNotNilAppStoreNotNilGooglePlayNotNilDetailsNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: "1",
            appStore: "appStore",
            googlePlay: "googlePlay",
            detail: nil)
        
        XCTAssertFalse(item.disableAction)
    }
    
    func test_disableAction_linkNotNilAppStoreNotNilGooglePlayNotNilDetailsNotNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: "1",
            appStore: "appStore",
            googlePlay: "googlePlay",
            detail: .init(groupId: "2", viewId: "3"))
        
        XCTAssertFalse(item.disableAction)
    }
    
    func test_disableAction_appStoreNotNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: nil,
            appStore: "1",
            googlePlay: nil,
            detail: nil)
        
        XCTAssertFalse(item.disableAction)
    }
    
    func test_disableAction_linkNilAppStoreNotNilGooglePlayNotNilDetailsNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: nil,
            appStore: "appStore",
            googlePlay: "googlePlay",
            detail: nil)
        
        XCTAssertFalse(item.disableAction)
    }
    
    func test_disableAction_linkNilAppStoreNotNilGooglePlayNotNilDetailsNotNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: nil,
            appStore: "appStore",
            googlePlay: "googlePlay",
            detail: .init(groupId: "2", viewId: "3"))
        
        XCTAssertFalse(item.disableAction)
    }

    func test_disableAction_googlePlayNotNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: nil,
            appStore: nil,
            googlePlay: "1",
            detail: nil)
        
        XCTAssertFalse(item.disableAction)
    }
    
    func test_disableAction_linkNilAppStoreNilGooglePlayNotNilDetailsNotNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: nil,
            appStore: nil,
            googlePlay: "googlePlay",
            detail: .init(groupId: "2", viewId: "3"))
        
        XCTAssertFalse(item.disableAction)
    }

    func test_disableAction_detailNotNil_shouldSetDisableActionFalse() {
        
        let item = createItem(
            link: nil,
            appStore: nil,
            googlePlay: nil,
            detail: .init(groupId: "1", viewId: "2"))
        
        XCTAssertFalse(item.disableAction)
    }

    // MARK: - test displayedCount
    
    func test_displayedCount_displayedCountNil_shouldCountIsListCount() {
        
        let sut = makeSUT(displayedCount: nil, items: [.default, .default])
        
        XCTAssertEqual(sut.displayedCount, 2)
    }
    
    func test_displayedCount_displayedCountNotNil_shouldCountIsDisplayCount() {
        
        let sut = makeSUT(displayedCount: 1, items: [.default, .default])
        
        XCTAssertEqual(sut.displayedCount, 1)
    }

    // MARK: - Helpers
    
    typealias ViewModel = ListVerticalRoundImageView.ViewModel
    typealias Item = UILanding.List.VerticalRoundImage.ListItem
    
    private func createItem(
        md5hash: String = "1",
        title: String? = nil,
        subInfo: String? = nil,
        link: String? = nil,
        appStore: String? = nil,
        googlePlay: String? = nil,
        detail: Item.Detail? = nil,
        action: Item.Action? = nil
    ) -> Item {
        
        .init(
            md5hash: md5hash,
            title: title,
            subInfo: subInfo,
            link: link,
            appStore: appStore,
            googlePlay: googlePlay,
            detail: detail,
            action: action
        )
    }
        
    private func makeSUT(
        title: String? = "title",
        displayedCount:  Double? = 1,
        dropButtonOpenTitle: String? = "dropButtonOpenTitle",
        dropButtonCloseTitle: String? = "dropButtonCloseTitle",
        items: [Item] = [.default],
        images: [String : Image] = [:],
        action: @escaping (LandingEvent) -> Void = {_ in },
        selectDetail: @escaping SelectDetail = { _ in },
        canOpenDetail: @escaping UILanding.CanOpenDetail = {_ in false }
    ) -> ListVerticalRoundImageView.ViewModel {
        
        return .init(
            data: .init(
                title: title,
                displayedCount: displayedCount,
                dropButtonOpenTitle: dropButtonOpenTitle,
                dropButtonCloseTitle: dropButtonCloseTitle,
                list: items),
            images: images,
            action: action,
            selectDetail: selectDetail,
            canOpenDetail: canOpenDetail
        )
    }
    
    private enum ActionType {
        
        case initinalValue
        case goMain
        case openLink
        case orderCard
        case selectDetail
    }
}

private extension UILanding.List.VerticalRoundImage.ListItem{
    
    static let `default`: Self = .init(
        md5hash: "md5hash",
        title: "title",
        subInfo: "subInfo",
        link: "link",
        appStore: "appStore",
        googlePlay: "googlePlay",
        detail: .init(groupId: "1", viewId: "2"), 
        action: nil)
}
