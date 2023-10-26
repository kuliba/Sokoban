//
//  SearchFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.05.2023.
//

import Combine
import Foundation
import TextFieldComponent

/// A namespace for factory methods used to create search fields (text input field).
enum SearchFactory {}

extension SearchFactory {
    
    static func makeSearchBanksField() -> RegularFieldViewModel {
        
        makeSearchFieldModel(for: .select(.banks), type: .other)
    }
    
    static func makeSearchContactsField() -> RegularFieldViewModel {
        
        makeSearchFieldModel(for: .select(.contacts), type: .other)
    }
    
    static func makeSearchCountriesField() -> RegularFieldViewModel {
        
        makeSearchFieldModel(for: .select(.countries), type: .other)
    }
    
    static func makeSearchFieldModel(
        for mode: ContactsViewModel.Mode,
        type: ContactsViewModel.PaymentsType,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> RegularFieldViewModel {
        
        
        let cleanup: (String) -> String = {
            switch type {
            case .abroad:
                guard $0.hasPrefix("8"),
                      $0.count > 1
                else { return $0 }
                
                return $0.shouldChangeTextIn(
                    range: .init(location: 0, length: 1),
                    with: "7"
                )
            default:
                return $0
            }
        }
        
        let substitutions = {
            switch type {
            case .abroad:
                
                return [CountryCodeReplace].russian
                    .map(\.substitution)
            default:
                return []
            }
        }()
                
        let format: (String) -> String = {
            
            guard !$0.isEmpty else { return $0 }
            
            return type == .abroad ?
            PhoneNumberKitWrapper.formatPartial(for: type, "+\($0)") :
            PhoneNumberKitWrapper.formatPartial(for: type, $0)
        }
        
        let contactsTextField = TextFieldFactory.contactTextField(
            placeholderText: mode.title,
            cleanup: cleanup,
            substitutions: substitutions,
            format: format,
            keyboardType: .default,
            scheduler: scheduler
        )
        
        let selectTextField = TextFieldFactory.makeTextField(
            text: nil,
            placeholderText: mode.title,
            keyboardType: .default,
            limit: nil,
            scheduler: scheduler
        )
        
        switch mode {
        case .fastPayments:
            return contactsTextField
            
        case .abroad:
            return TextFieldFactory.makeTextField(
                placeholderText: mode.title,
                transformer: Transform(build: {
                    
                    Transformers.Filtering.letters
                }),
                keyboardType: .default,
                scheduler: scheduler
            )
            
        case let .select(select):
            switch select {
            case .contacts:
                return contactsTextField
                
            case .banks, .banksFullInfo, .countries:
                return selectTextField
            }
        }
    }
}

extension TextViewPhoneNumberView.ViewModel: PhoneNumberTextFieldViewModel {
    
    var textPublisher: AnyPublisher<String?, Never> {
        
        $text.eraseToAnyPublisher()
    }
    var phoneNumberState: State {
        
        get { state }
        set { state = newValue }
    }
    var phoneNumberStatePublisher: AnyPublisher<State, Never> {
        
        $state.eraseToAnyPublisher()
    }
    
    func partialFormatter(_ phoneNumber: String) -> String {
        
        phoneNumberFormatter.partialFormatter(phoneNumber)
    }
    
    func startEditing() {
        
        state = .editing
    }
    
    func finishEditing() {
        
        state = .idle
    }
}

extension ReducerTextFieldViewModel: PhoneNumberTextFieldViewModel {
    
    var textPublisher: AnyPublisher<String?, Never> {
        
        textPublisher()
    }
    
    var phoneNumberState: TextViewPhoneNumberView.ViewModel.State {
        get { state.phoneNumberState }
        set { finishEditing() }
    }
    
    var phoneNumberStatePublisher: AnyPublisher<TextViewPhoneNumberView.ViewModel.State, Never> {
        
        $state
            .map(\.phoneNumberState)
            .eraseToAnyPublisher()
    }
    
    var dismissKeyboard: () -> Void {
        
        return finishEditing
    }
}

extension TextFieldState {
    
    var phoneNumberState: TextViewPhoneNumberView.ViewModel.State {
        
        switch self {
        case .editing:
            return .editing
        case .noFocus:
            return .selected
        case .placeholder:
            return .idle
        }
    }
}
