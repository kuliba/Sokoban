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
        }
        
    }
}

//MARK: - Handlers

extension Model {
    
    func handleContactsPermissionStatusRequest() {
            
        contactsAgent.requestPermission()
    }
   
    func contact(for phoneNumber: String) -> AddressBookContact? {
        
        contactsAgent.fetchContact(by: phoneNumber)
        
    }
}
