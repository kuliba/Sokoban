//
//  SearchBarComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import SwiftUI
import Combine

extension SearchBarView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let icon: Image?
        @Published var textFieldPhoneNumberView: TextFieldPhoneNumberView.ViewModel
        var text: String? { textFieldPhoneNumberView.text }
        var isValidation: Bool {
            if let text = text {
                return phoneNumberFormater.isValidate(text)
            }
            return false
        }
        
        @Published var state: State
        
        private let phoneNumberFormater = PhoneNumberFormater()
        private var bindings = Set<AnyCancellable>()
        
        init(textFieldPhoneNumberView: TextFieldPhoneNumberView.ViewModel, state: State = .idle, icon: Image? = nil, isValidation: Bool = false) {
            
            self.textFieldPhoneNumberView = textFieldPhoneNumberView
            self.state = state
            self.icon = icon
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case _ as SearchBarViewModelAction.ChangeState:
                        self.state = .idle
                        
                    case _ as SearchBarViewModelAction.ClearTextField:
                        self.textFieldPhoneNumberView.text = nil
                        
                    default: break
                    }
                    
                }.store(in: &bindings)
            
            textFieldPhoneNumberView.$isSelected
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isSelected in
            
                    if isSelected && (text != "" && text != nil) {
                        
                        state = .editing(.init(type: .icon(.ic24Close), action: {
                            
                            self.action.send(SearchBarViewModelAction.ClearTextField())
                        }), .init(type: .title("Отмена"), action: {

                            self.action.send(SearchBarViewModelAction.ChangeState(state: .idle))
                        }))
                        
                    } else if isSelected {
                        
                        state = .selected(.init(type: .title("Отмена"), action: {
                            
                            self.action.send(SearchBarViewModelAction.ChangeState(state: .idle))
                        }))
                        
                    } else {
                        state = .idle
                    }
                    
                }.store(in: &bindings)
            
            textFieldPhoneNumberView.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    if text != nil && text != "" {

                        self.state = .editing(.init(type: .icon(.ic24Close), action: {

                            self.action.send(SearchBarViewModelAction.ClearTextField())
                        }), .init(type: .title("Отмена"), action: {

                            self.action.send(SearchBarViewModelAction.ChangeState(state: .idle))
                        }))

                    } else if textFieldPhoneNumberView.isSelected {
                        
                        state = .selected(.init(type: .title("Отмена"), action: {
                            
                            self.action.send(SearchBarViewModelAction.ChangeState(state: .idle))
                        }))
                    }
                    
                    action.send(SearchBarViewModelAction.Number.isValidation(isValidation: isValidation))
                    
                }.store(in: &bindings)
            
            $state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in
                    
                    switch state {
                        
                    case .idle:
                        self.textFieldPhoneNumberView.dismissKeyboard()
                    
                    default: break
                    }
                    
                }.store(in: &bindings)
        }
        
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
}

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
            
            TextFieldPhoneNumberView(viewModel: viewModel.textFieldPhoneNumberView)
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

struct SearchBarViewModelAction {
    
    struct ChangeState: Action {
        
        let state: SearchBarView.ViewModel.State
    }
    
    struct ClearTextField: Action {}
    
    struct Number {
        
        struct isValidation: Action {
            
            let isValidation: Bool
        }
    }
}

struct SearchBarComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {

            SearchBarView(viewModel: .init(textFieldPhoneNumberView: .init(placeHolder: .contacts)))
                .previewLayout(.fixed(width: 375, height: 100))

            SearchBarView(viewModel: .init(textFieldPhoneNumberView: .init(placeHolder: .banks)))
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}
