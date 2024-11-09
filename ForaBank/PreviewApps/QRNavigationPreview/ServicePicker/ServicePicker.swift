//
//  ServicePicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.11.2024.
//

import Combine

final class ServicePicker {
    
    func publisher(
        for keyPath: KeyPath<Event, Void?>
    ) -> AnyPublisher<Void, Never> {
        
        return eventSubject
            .compactMap { $0[keyPath: keyPath] }
            .eraseToAnyPublisher()
    }
    
    func addCompany() { eventSubject.send(.goToChat) }
    func goToMain() { eventSubject.send(.goToMain) }
    func goToPayments() { eventSubject.send(.goToPayments) }
    
    // MARK: - Event
    
    private let eventSubject = PassthroughSubject<Event, Never>()
    
    enum Event {
        
        case goToChat, goToMain, goToPayments
        
        var goToChat: Void? { self == .goToChat ? () : nil }
        var goToMain: Void? { self == .goToMain ? () : nil }
        var goToPayments: Void? { self == .goToPayments ? () : nil }
    }
}
