//
//  ContactsViewModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 18.10.2022.
//

import XCTest
@testable import ForaBank

final class ContactsViewModelTests: XCTestCase {

    func testTopBanksReduce() throws {
        
        // given
        let model: Model = .emptyMock
        let reduceBank = ContactsViewModel(model).reduce(model: model, banks: [.init(bankId: "bankId", bankName: "bankName", payment: true, defaultBank: false)])
        
        // when
        let result = ContactsViewModel.TopBanksViewModel(banks: [.init(image: nil, defaultBank: false, name: nil, bankName: "bankName", action: {})])
        
        // then
        XCTAssertEqual(reduceBank, result)
    }
    
    func testBanksItemReduce() throws {
        
        // given
        let reduceBank = ContactsViewModel.BanksSectionCollapsableViewModel.reduceBanks(banksData: [.init(md5hash: "md5hash", memberId: "memberId", memberName: "memberName", memberNameRus: "memberNameRus", paymentSystemCodeList: ["SFP"], svgImage: .init(description: ""))])
        
        //when
        let result = [ContactsViewModel.CollapsableSectionViewModel.ItemViewModel(title: "memberNameRus", image: nil, bankType: .sfp, action: {})]

        // then
        XCTAssertEqual(reduceBank, result)
    }
    
    func testBanksItemReduceWithFilterByType() throws {
        
        // given
        let reduceBank = ContactsViewModel.BanksSectionCollapsableViewModel.reduceBanks(banksData: [.init(md5hash: "md5hash", memberId: "memberId", memberName: "memberName", memberNameRus: "memberNameRus", paymentSystemCodeList: ["SFP"], svgImage: .init(description: "")), .init(md5hash: "md5hash", memberId: "memberId", memberName: "memberName", memberNameRus: "memberNameRus", paymentSystemCodeList: ["DIRECT"], svgImage: .init(description: ""))], filterByType: .sfp)

        
        //when
        let result = [ContactsViewModel.CollapsableSectionViewModel.ItemViewModel(title: "memberNameRus", image: nil, bankType: .sfp, action: {})]

        // then
        XCTAssertEqual(reduceBank, result)
    }
    
    func testBanksItemReduceWithFilterByName() throws {
        
        // given
        let reduceBank = ContactsViewModel.BanksSectionCollapsableViewModel.reduceBanks(banksData: [.init(md5hash: "md5hash", memberId: "memberId", memberName: "memberName", memberNameRus: "memberNameRus", paymentSystemCodeList: ["SFP"], svgImage: .init(description: "")), .init(md5hash: "md5hash", memberId: "memberId", memberName: "memberName", memberNameRus: "notEqualName", paymentSystemCodeList: ["DIRECT"], svgImage: .init(description: ""))], filterByName: "memberNameRus")

        
        //when
        let result = [ContactsViewModel.CollapsableSectionViewModel.ItemViewModel(title: "memberNameRus", image: nil, bankType: .sfp, action: {})]

        // then
        XCTAssertEqual(reduceBank, result)
    }
}
