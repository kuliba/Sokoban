//
//  ContactsAgentProtocol.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 23.05.2022.
//

import Combine
import Contacts

protocol ContactsAgentProtocol {
    
    var status: CurrentValueSubject<ContactsAgentStatus, Never> { get }
    
    func fetchContact(by phoneNumber: String) -> AddressBookContact?
    func requestPermission()
}

enum ContactsAgentStatus {
    
    case disabled
    case available
    case failed(Error?)
    
    init(with status: CNAuthorizationStatus) {
        
        switch status {
        case .authorized:
            self = .available
            
        default:
            self = .disabled
        }
    }
}


