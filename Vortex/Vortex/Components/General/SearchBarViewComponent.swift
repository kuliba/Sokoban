//
//  SearchBarComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import SwiftUI
import Combine
import TextFieldComponent

protocol PhoneNumberTextFieldViewModel: ObservableObject {
    
    var text: String? { get }
    var textPublisher: AnyPublisher<String?, Never> { get }
    var phoneNumberState: TextViewPhoneNumberView.ViewModel.State { get set }
    var phoneNumberStatePublisher: AnyPublisher<TextViewPhoneNumberView.ViewModel.State, Never> { get }
    var dismissKeyboard: () -> Void { get }
    
    func setText(to text: String?)
    func startEditing()
    func finishEditing()
}

extension SearchBarView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<SearchBarViewModelAction, Never> = .init()
        
        let icon: Image?
        let textFieldModel: any PhoneNumberTextFieldViewModel
        var text: String? { textFieldModel.text }
        var phone: String? {
#if DEBUG
            if text == "+7 0115110217" { return text }
#endif
            guard let text = text, validator.isValid(text) else {
                return nil
            }
            
            return text
        }
        
        @Published private(set) var state: State
        
        private let validator: Validator
        private var bindings = Set<AnyCancellable>()
        private let scheduler: AnySchedulerOfDispatchQueue
        
        init(
            textFieldModel: any PhoneNumberTextFieldViewModel,
            validator: Validator = PhoneValidator(),
            state: State = .idle,
            icon: Image? = nil,
            scheduler: AnySchedulerOfDispatchQueue = .makeMain()
        ) {
            
            self.textFieldModel = textFieldModel
            self.validator = validator
            self.state = state
            self.icon = icon
            self.scheduler = scheduler
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: scheduler)
                .sink { [unowned self] action in
                    
                    switch action {
                    case .dismissKeyboard:
                        self.textFieldModel.dismissKeyboard()
                        
                    case .clearTextField:
                        self.textFieldModel.setText(to: nil)
                        
                    case .idle:
                        self.state = .idle
                        self.textFieldModel.dismissKeyboard()
                    }
                    
                }.store(in: &bindings)
            
            textFieldModel.phoneNumberStatePublisher
                .receive(on: scheduler)
                .sink { [unowned self] state in
                    
                    switch state {
                    case .idle:
                        self.state = .idle
                        
                    case .selected:
                        self.state = .selected(.init(type: .title("Отмена"), action: { [weak self] in
                            
                            self?.action.send(.clearTextField)
                            self?.action.send(.dismissKeyboard)
                        }))
                        
                    case .editing:
                        
                        switch self.state {
                        case .idle, .selected:
                            self.state = .editing(.init(type: .icon(.ic24Close), action: { [weak self] in
                                
                                self?.action.send(.clearTextField)
                                
                            }), .init(type: .title("Отмена"), action: { [weak self] in
                                
                                self?.action.send(.clearTextField)
                                self?.action.send(.dismissKeyboard)
                            }))
                            
                        default:
                            break
                        }
                    }
                    
                }.store(in: &bindings)
        }
    }
}

// MARK: - SearchBarView.ViewModel factory helpers

extension SearchBarView.ViewModel {
    
    static func banks() -> SearchBarView.ViewModel {
        
        searchBar(for: .select(.banks(phone: nil)))
    }
    
    static func contacts() -> SearchBarView.ViewModel {
        
        searchBar(for: .select(.contacts))
    }
    
    static func countries() -> SearchBarView.ViewModel {
        
        searchBar(for: .select(.countries))
    }
    
    static func generalWithText(
        _ text: String
    ) -> SearchBarView.ViewModel {
        
        let textField = TextViewPhoneNumberView.ViewModel(
            style: .general,
            placeHolder: .text(text)
        )
        
        return .init(
            textFieldModel: textField,
            state: .idle,
            icon: .ic24Search
        )
    }
    
    static func nameOrTaxCode() -> SearchBarView.ViewModel {
        
        return .generalWithText("Название или ИНН")
    }
    
    static func searchBar(
        for mode: ContactsViewModel.Mode
    ) -> SearchBarView.ViewModel {
        
        switch mode {
        case .fastPayments:
            let textField = TextViewPhoneNumberView.ViewModel(.contacts)
            return .init(textFieldModel: textField)
            
        case .abroad:
            let textField = TextViewPhoneNumberView.ViewModel(style: .abroad, placeHolder: .countries)
            return .init(textFieldModel: textField, state: .idle, icon: .ic24Search)
            
        case let .select(select):
            switch select {
            case .contacts:
                let textField = TextViewPhoneNumberView.ViewModel(.contacts)
                return .init(textFieldModel: textField)
                
            case .banks:
                let textField = TextViewPhoneNumberView.ViewModel(.banks)
                return .init(textFieldModel: textField)
                
            case .banksFullInfo:
                let textField = TextViewPhoneNumberView.ViewModel(style: .banks, placeHolder: .banks)
                return .init(textFieldModel: textField)
                
            case .countries:
                let textField = TextViewPhoneNumberView.ViewModel(.countries)
                return .init(textFieldModel: textField)
            }
        }
    }
    
    static func withText(_ text: String) -> SearchBarView.ViewModel {
        
        let textFieldModel = TextViewPhoneNumberView.ViewModel(.text(text))
        
        return .init(textFieldModel: textFieldModel)
    }
}

//MARK: - Types

extension SearchBarView.ViewModel {
    
    enum State {
        
        case idle
        case selected(Button)
        case editing(Button, Button)
    }
    
    struct Button: Identifiable {
        
        let id = UUID()
        let type: Kind
        let action: () -> Void
        
        enum Kind {
            
            case icon(Image)
            case title(String)
        }
    }
}

//MARK: - Action

enum SearchBarViewModelAction {
    
    case dismissKeyboard
    case clearTextField
    case idle
}

//MARK: - View

struct SearchBarView: View {
    
    @ObservedObject var viewModel: SearchBarView.ViewModel
    
    var body: some View {
        
        HStack {
            
            if let icon = viewModel.icon {
                
                icon
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 16, height: 16)
            }
            
            TextViewPhoneNumberView(viewModel: viewModel.textFieldModel as! TextViewPhoneNumberView.ViewModel)
                .frame(height: 44)
                .cornerRadius(8)
            
            switch viewModel.state {
                
            case .idle:
                EmptyView()
                
            case let .editing(clearButton, cancelButton):
                HStack(spacing: 20) {
                    
                    ButtonView(viewModel: clearButton)
                    
                    ButtonView(viewModel: cancelButton)
                }
                
            case let .selected(cancelButton):
                ButtonView(viewModel: cancelButton)
                
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 15)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.bordersDivider, lineWidth: 1)
        )
    }
    
    struct ButtonView: View {
        
        let viewModel: SearchBarView.ViewModel.Button
        
        var body: some View {
            
            Button(action: {
                
                viewModel.action()
                
            }) {
                
                switch viewModel.type {
                    
                case let .icon(icon):
                    icon
                        .resizable()
                        .frame(width: 12, height: 12, alignment: .center)
                        .foregroundColor(.mainColorsGray)
                    
                case let .title(title):
                    Text(title)
                        .foregroundColor(.mainColorsGray)
                        .font(Font.system(size: 14))
                }
                
            }
        }
    }
}

struct SearchBarComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            previewsGroup()
            
            VStack(content: previewsGroup)
                .previewDisplayName("Xcode 14")
        }
        .previewLayout(.sizeThatFits)
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            SearchBarView(viewModel: .banks())
            SearchBarView(viewModel: .contacts())
            SearchBarView(viewModel: .countries())
            SearchBarView(viewModel: .generalWithText("Any text here (general)"))
            SearchBarView(viewModel: .nameOrTaxCode())
            SearchBarView(viewModel: .withText("Any text here"))
        }
        .previewLayout(.fixed(width: 375, height: 100))
    }
}
