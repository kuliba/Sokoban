//
//  ContactsViewModelModeTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.05.2023.
//

@testable import ForaBank
import XCTest

final class ContactsViewModelModeTests: XCTestCase {
    
    // MARK: - visibleSectionsTypes
    
    func test_abroad() {
        
        let mode: ContactsViewModel.Mode = .abroad
        
        XCTAssertEqual(mode.visibleSectionsTypes, [
            .latestPayments, .countries
        ])
    }
    
    func test_fastPayments_contacts() {
        
        let mode: ContactsViewModel.Mode = .fastPayments(.contacts)
        
        XCTAssertEqual(mode.visibleSectionsTypes, [
            .latestPayments, .contacts
        ])
    }
    
    func test_fastPayments_banksAndCountries_empty() {
        
        let mode: ContactsViewModel.Mode = .fastPayments(.banksAndCountries(phone: ""))
        
        XCTAssertEqual(mode.visibleSectionsTypes, [
            .banksPreferred, .banks, .countries
        ])
    }
    
    func test_fastPayments_banksAndCountries_nonEmpty() {
        
        let mode: ContactsViewModel.Mode = .fastPayments(.banksAndCountries(phone: "123"))
        
        XCTAssertEqual(mode.visibleSectionsTypes, [
            .banksPreferred, .banks, .countries
        ])
    }
    
    func test_select_contacts() {
        
        let mode: ContactsViewModel.Mode = .select(.contacts)
        
        XCTAssertEqual(mode.visibleSectionsTypes, [
            .contacts
        ])
    }
    
    func test_select_banks() {
        
        let mode: ContactsViewModel.Mode = .select(.banks(phone: nil))
        
        XCTAssertEqual(mode.visibleSectionsTypes, [
            .banks
        ])
    }
    
    func test_select_banksFullInfo() {
        
        let mode: ContactsViewModel.Mode = .select(.banksFullInfo)
        
        XCTAssertEqual(mode.visibleSectionsTypes, [
            .banks
        ])
    }
    
    func test_select_countries() {
        
        let mode: ContactsViewModel.Mode = .select(.countries)
        
        XCTAssertEqual(mode.visibleSectionsTypes, [
            .countries
        ])
    }
    
    // MARK: - title
    
    func test_title() {
        
        typealias Mode = ContactsViewModel.Mode
        
        XCTAssertEqual(Mode.fastPayments(.contacts).title, "Выберите контакт")
        XCTAssertEqual(Mode.fastPayments(.banksAndCountries(phone: "")).title, "Выберите контакт")
        XCTAssertEqual(Mode.fastPayments(.banksAndCountries(phone: "123")).title, "Выберите контакт")
        XCTAssertEqual(Mode.abroad.title, "В какую страну?")
        XCTAssertEqual(Mode.select(.contacts).title, "Выберите контакт")
        XCTAssertEqual(Mode.select(.banks(phone: nil)).title, "Выберите банк")
        XCTAssertEqual(Mode.select(.banksFullInfo).title, "Выберите банк")
        XCTAssertEqual(Mode.select(.countries).title, "Выберите страну")
    }
}
