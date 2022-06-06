//
//  ContactsAgentTest.swift
//  ForaBankTests
//
//  Created by Dmitry Martynov on 06.06.2022.
//

import XCTest
@testable import ForaBank

class ContactsAgentTests: XCTestCase {
    
    let contactsAgent = ContactsAgent()

    

    func testClearNumber() throws {
    
        // given
        let clearNumber: String = "+79266053833"
        
        // when
        
        let result: String = contactsAgent.clearNumber(for: "+7(926) 605-38-33")
        
        XCTAssertEqual(result, clearNumber)
    }
    
    
}
