//
//  AlertViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Foundation

typealias AlertViewModelOf<Event> = AlertViewModel<Event, Event>

struct AlertViewModel<PrimaryEvent, SecondaryEvent>: Identifiable {
    
    let id: UUID
    let title: String
    let message: String?
    let primaryButton: ButtonViewModel<PrimaryEvent>
    let secondaryButton: ButtonViewModel<SecondaryEvent>?
    
    init(
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

struct ButtonViewModel<Event> {
    
    let type: ButtonType
    let title: String
    let event: Event
    
    enum ButtonType: Equatable {
        
        case `default`, destructive, cancel
    }
}

extension AlertViewModel: Equatable where PrimaryEvent: Equatable, SecondaryEvent: Equatable {}

extension ButtonViewModel: Equatable where Event: Equatable {}
