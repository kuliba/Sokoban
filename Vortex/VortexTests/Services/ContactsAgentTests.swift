//
//  ContactsAgentTest.swift
//  VortexTests
//
//  Created by Dmitry Martynov on 06.06.2022.
//

import XCTest
@testable import Vortex

class ContactsAgentTests: XCTestCase {
    
    let contactsAgent = ContactsAgent(phoneNumberFormatter: PhoneNumberKitFormater())

    func testClearNumber() throws {
        
            // given
            let phoneNumber = "+7(926) 605-38-33"
            let expected = "+79266053833"
            
            // when
            let result = contactsAgent.clearNumber(for: phoneNumber)
            
            // then
            XCTAssertEqual(result, expected)
        }
}
