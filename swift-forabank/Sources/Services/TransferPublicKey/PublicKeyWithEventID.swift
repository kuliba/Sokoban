//
//  PublicKeyWithEventID.swift
//  
//
//  Created by Igor Malyarov on 21.08.2023.
//

import Foundation

public struct PublicKeyWithEventID<EventID> {
    
    public let eventID: EventID
    public let data: Data
}
