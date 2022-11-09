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
        let textField: TextFieldPhoneNumberView.ViewModel
        var text: String? { textField.text }
        var phone: String? {
            
#if DEBUG
            guard let text = text else {
                return nil
            }
            
            guard phoneNumberFormater.isValid(text) || text == "+7 0115110217" else {
                return nil
            }
            
            return text
#else
            guard let text = text, phoneNumberFormater.isValid(text) else {
                return nil
            }
            
            return text
#endif
        }
        
        @Published private(set) var state: State
        
        private let phoneNumberFormater = PhoneNumberKitFormater()
        private var bindings = Set<AnyCancellable>()
        
        init(textFieldPhoneNumberView: TextFieldPhoneNumberView.ViewModel, state: State = .idle, icon: Image? = nil) {
            
            self.textField = textFieldPhoneNumberView
            self.state = state
            self.icon = icon
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as SearchBarViewModelAction.DismissKeyboard:
                        self.textField.dismissKeyboard()
                        
                    case _ as SearchBarViewModelAction.ClearTextField:
                        self.textField.text = nil
                        
                    case _ as SearchBarViewModelAction.Idle:
                        self.state = .idle
                        self.textField.dismissKeyboard()
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            textField.$state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in
                    
                    switch state {
                    case .idle:
                        self.state = .idle
                        
                    case .selected:
                        self.state = .selected(.init(type: .title("Отмена"), action: { [weak self] in
                            
                            self?.action.send(SearchBarViewModelAction.DismissKeyboard())
                        }))
                        
                    case .editing:
                        
                        switch self.state {
                        case .idle, .selected:
                            self.state = .editing(.init(type: .icon(.ic24Close), action: { [weak self] in
                                
                                self?.action.send(SearchBarViewModelAction.ClearTextField())
                                
                            }), .init(type: .title("Отмена"), action: { [weak self] in
                                
                                self?.action.send(SearchBarViewModelAction.DismissKeyboard())
                            }))
                            
                        default:
                            break
                        }
                    }
                    
                }.store(in: &bindings)
        }
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

struct SearchBarViewModelAction {
    
    struct DismissKeyboard: Action {}
    
    struct ClearTextField: Action {}
        
    struct Idle: Action {}
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
            
            TextFieldPhoneNumberView(viewModel: viewModel.textField)
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
            
            SearchBarView(viewModel: .init(textFieldPhoneNumberView: .init(placeHolder: .contacts)))
                .previewLayout(.fixed(width: 375, height: 100))
            
            SearchBarView(viewModel: .init(textFieldPhoneNumberView: .init(placeHolder: .banks)))
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}
