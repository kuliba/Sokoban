//
//  Model+Contacts.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 01.06.2022.
//

import Foundation

//MARK: - Action

extension ModelAction {
    
    enum Contacts {
  
        enum PermissionStatus {
        
            struct Request: Action {}
            
            struct Update: Action {
                
                let status: ContactsAgentStatus
            }
        }
        
    }
}

//MARK: - Handlers

extension Model {
    
    var contactsPermissionStatus: ContactsAgentStatus {
        
        contactsAgent.status.value
    }
    
    func handleContactsPermissionStatusRequest() {
            
        contactsAgent.requestPermission()
    }
   
    func contact(for phoneNumber: String) -> AddressBookContact? {
        
        contactsAgent.fetchContact(by: phoneNumber)
    }
    
    func contactsFetchAll() async throws -> [AddressBookContact] {
        
        try contactsAgent.fetchContactsList()
    }
}
