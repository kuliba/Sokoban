//
//  UserAccountViewModelTests.swift
//  ForaBankTests
//
//  Created by Andrew Kurdin on 19.10.2023.
//

import Combine
@testable import ForaBank
import XCTest

final class UserAccountViewModelTests: XCTestCase {

    func test_init_shouldNotCallSettings() {
        
        let (_, _, spy) = makeSUT()
        
        XCTAssertNoDiff(spy.loadAttempts, [])
        XCTAssertNoDiff(spy.storeAttempts, [])
        XCTAssertNoDiff(spy.clearAttempts, [])
    }
    
    func test_init_storred_nil() {
        
        let (_, _, spy) = makeSUT()
        
        XCTAssertNil(spy.storred)
    }
    
    func test_init_shouldNotCallSettings_true() {
        
        let data = Data("true".utf8)
        let (_, _, spy) = makeSUT(storred: (data, .interface(.sticker)))
        
        XCTAssertNoDiff(spy.loadAttempts, [])
        XCTAssertNoDiff(spy.storeAttempts, [])
        XCTAssertNoDiff(spy.clearAttempts, [])
    }
    
    func test_init_shouldSetSetting_true() {
        
        let data = Data("true".utf8)
        let (_, _, spy) = makeSUT(storred: (data, .interface(.sticker)))
        
        XCTAssertNoDiff(spy.storred?.0, .init("true".utf8))
        XCTAssertNoDiff(spy.storred?.1, .interface(.sticker))
    }
    
    func test_init_shouldNotCallSettings_false() {
       
        let data = Data("false".utf8)
        let (_, _, spy) = makeSUT(storred: (data, .interface(.sticker)))
        
        XCTAssertNoDiff(spy.loadAttempts, [])
        XCTAssertNoDiff(spy.storeAttempts, [])
        XCTAssertNoDiff(spy.clearAttempts, [])
    }
    
    func test_init_shouldSetSetting_false() {
        
        let data = Data("false".utf8)
        let (_, _, spy) = makeSUT(storred: (data, .interface(.sticker)))
        
        XCTAssertNoDiff(spy.storred?.0, .init("false".utf8))
        XCTAssertNoDiff(spy.storred?.1, .interface(.sticker))
    }
    
    /*
    func test_logout_shouldSaveStickerSetting() {
        
        let (sut, _, spy) = makeSUT()
        
        sut.logout()
        
        XCTAssertNoDiff(spy.storeAttempts, [.interface(.sticker)])
        XCTAssertNoDiff(spy.storred?.0, .init("true".utf8))
        XCTAssertNoDiff(spy.storred?.1, .interface(.sticker))
    }
    
    func test_logout_shouldSaveStickerSetting_true() {
        
        let data = Data("true".utf8)
        let (sut, _, spy) = makeSUT(storred: (data, .interface(.sticker)))
        
        sut.logout()
        
        XCTAssertNoDiff(spy.storeAttempts, [.interface(.sticker)])
        XCTAssertNoDiff(spy.storred?.0, .init("true".utf8))
        XCTAssertNoDiff(spy.storred?.1, .interface(.sticker))
    }
    
    func test_logout_shouldSaveStickerSetting_false() {
        
        let data = Data("false".utf8)
        let (sut, _, spy) = makeSUT(storred: (data, .interface(.sticker)))
        
        sut.logout()
        
        XCTAssertNoDiff(spy.storeAttempts, [.interface(.sticker)])
        XCTAssertNoDiff(spy.storred?.0, .init("true".utf8))
        XCTAssertNoDiff(spy.storred?.1, .interface(.sticker))
    }
    */
    
    // MARK: - Helpers
    
    private typealias SUT = UserAccountViewModel
    
    private func makeSUT(
        storred: (Data, SettingType)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        model: Model,
        spy: SettingsAgentSpy
    ) {
        let spy = SettingsAgentSpy(storred: storred)
        let model: Model = .mockWithEmptyExcept(
            settingsAgent: spy
        )
        let sut = SUT(
            navigationStateManager: .preview,
            model: model,
            clientInfo: .sample,
            dismissAction: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, model, spy)
    }
}

// MARK: - DSL

private extension UserAccountViewModel {
    
    func logout() {
        
        action.send(UserAccountViewModelAction.ExitAction())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
       
        if let alert = route.alert {
            
            self.event(.alertButtonTapped(alert.primaryButton.event))
        } else {
            
            XCTFail("Expected none nil Alert")
        }
    }
}

private extension ClientInfoData {
    
    static let sample: Self = .init(id: 111, lastName: "qwe", firstName: "qwe", patronymic: "qwe", birthDay: "qwe", regSeries: "qwe", regNumber: "qwe", birthPlace: "qwe", dateOfIssue: "qwe", codeDepartment: "qwe", regDepartment: "qwe", address: "qwe", addressInfo: nil, addressResidential: "qwe", addressResidentialInfo: nil, phone: "qwe", phoneSMS: "qwe", email: "qwe", inn: "qwe", customName: "qwe")
}
