//
//  Receiver.swift
//  
//
//  Created by Igor Malyarov on 26.06.2024.
//

public protocol Receiver<Message> {
    
    associatedtype Message
    
    func receive(_ message: Message)
}
