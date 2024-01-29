//
//  AlertModel.swift
//
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation

public struct AlertModel<PrimaryEvent, SecondaryEvent>: Identifiable {
    
    public let id: UUID
    public let title: String
    public let message: String?
    public let primaryButton: ButtonViewModel<PrimaryEvent>
    public let secondaryButton: ButtonViewModel<SecondaryEvent>?
    
    public init(
        id: UUID = .init(),
        title: String,
        message: String?,
        primaryButton: ButtonViewModel<PrimaryEvent>,
        secondaryButton: ButtonViewModel<SecondaryEvent>? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

public struct ButtonViewModel<Event> {
    
    public let type: ButtonType
    public let title: String
    public let event: Event
    
    public init(
        type: ButtonType,
        title: String,
        event: Event
    ) {
        self.type = type
        self.title = title
        self.event = event
    }
    
    public enum ButtonType: Equatable {
        
        case `default`, destructive, cancel
    }
}

extension AlertModel: Equatable where PrimaryEvent: Equatable, SecondaryEvent: Equatable {}
//extension AlertModel: Hashable where PrimaryEvent: Hashable, SecondaryEvent: Hashable {}

extension ButtonViewModel: Equatable where Event: Equatable {}
//extension ButtonViewModel: Hashable where Event: Hashable {}
