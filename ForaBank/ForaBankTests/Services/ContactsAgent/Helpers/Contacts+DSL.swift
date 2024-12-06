//
//  Contacts+DSL.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 14.11.2023.
//

@testable import ForaBank
import XCTest

extension XCTestCase {
    
    func assertContacts(
        _ contacts: [AddressBookContact],
        _ equatableContacts: [AddressBookContact.EquatableAddressBookContact],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(
            contacts.map(\.equatable),
            equatableContacts,
            file: file, line: line
        )
    }
}

extension AddressBookContact {
    
    struct EquatableAddressBookContact: Equatable {
        
        var id: String { phone }
        let phone: String
        let firstName: String?
        let middleName: String?
        let lastName: String?
        let avatar: ImageData?
    }

    var equatable: EquatableAddressBookContact {
        .init(
            phone: self.phone,
            firstName: self.firstName,
            middleName: self.middleName,
            lastName: self.lastName,
            avatar: self.avatar)
    }
}
