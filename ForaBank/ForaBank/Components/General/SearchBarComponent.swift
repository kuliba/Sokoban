//
//  SearchBarComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import SwiftUI
import Combine

extension SearchBarComponent {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let icon: Image?
        @Published var text: String
        let placeHolder: PlaceHolder
        @Published var additionalButtons: [Button]
        var textColor: Color
        @Published var isValidation: Bool
        @Published var state: State
        
        private let phoneNumberFormater = PhoneNumberFormater()
        private var bindings = Set<AnyCancellable>()
        
        internal init(state: State, additionalButtons: [Button], placeHolder: PlaceHolder, icon: Image? = nil, text: String = "", textColor: Color, isValidation: Bool = false) {
            
            self.state = state
            self.additionalButtons = additionalButtons
            self.placeHolder = placeHolder
            self.icon = icon
            self.text = text
            self.textColor = textColor
            self.isValidation = isValidation
            
            bind()
        }
        
        convenience init(placeHolder: PlaceHolder) {
            
            self.init(state: .default, additionalButtons: [], placeHolder: placeHolder, textColor: .textPlaceholder)
            
            let cancelButton = Button.init(type: .title("Отмена"), action: {
                
                self.action.send(ViewModelAction.ChangeState(state: .hide))
                
            })
            
            let closeButton = Button.init(type: .icon(.ic24Close), action: {
                
                self.action.send(ViewModelAction.ClearTextField())
            })
            
            self.additionalButtons = [closeButton ,cancelButton]
        }
        
        enum State {
            
            case `default`
            case editing
            case hide
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
        
        enum PlaceHolder: String {
            
            case contacts = "Номер телефона или имя"
            case banks = "Введите название банка"
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case let payload as ViewModelAction.ChangeState:
                        self.state = payload.state
                    
                    case _ as ViewModelAction.ClearTextField:
                        self.text = ""
                        
                    default: break
                    }
        
                }.store(in: &bindings)
            
            $text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in
                    
                    guard phoneNumberFormater.isValidate(text) else {
                        isValidation = false
                        return
                    }
                    
                    withAnimation {
                        
                        isValidation = true
                    }
                    
                }.store(in: &bindings)
        }
    }
}

struct PhoneNumberTextFieldView: UIViewRepresentable {
    
    var textField = UITextField()
    let phoneNumberKit = PhoneNumberFormater()

    @ObservedObject var viewModel: SearchBarComponent.ViewModel
    
    func makeUIView(context: Context) -> UITextField {
        
        textField.addTarget(context.coordinator, action: #selector(Coordinator.onTextChange), for: .editingChanged)
        textField.placeholder = viewModel.placeHolder.rawValue
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.shouldHideToolbarPlaceholder = false
        textField.spellCheckingType = .no
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
        uiView.text = self.viewModel.text
        
        if self.viewModel.state == .hide {
            
            self.textField.endEditing(false)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    typealias UIViewType = UITextField
    
    class Coordinator:  NSObject, UITextFieldDelegate {
        var delegate: PhoneNumberTextFieldView
        
        init(_ delegate: PhoneNumberTextFieldView) {
            self.delegate = delegate
        }
        
        @objc func onTextChange(textField: UITextField) {
            
            if let text = textField.text {
                
                self.delegate.viewModel.state = .editing
                self.delegate.viewModel.text = text
                self.delegate.textField.text = self.delegate.phoneNumberKit.partialFormatter(text)
            }
        }
        
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            print("textFieldShouldEndEditing")
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            print("it's should change Characters \(String(describing: textField.text))")
            return true
        }
    }
}

struct SearchBarComponent: View {
    
    @ObservedObject var viewModel: SearchBarComponent.ViewModel
    
    var body: some View {
        
        HStack {
            
            if let icon = viewModel.icon {
                
                icon
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 16, height: 16)
            }
            
            PhoneNumberTextFieldView(viewModel: viewModel)
                .frame(height: 44)
                .cornerRadius(8)
                .foregroundColor(viewModel.textColor)
                
            if viewModel.state == .editing {
                
                HStack(spacing: 20) {
                    
                    ForEach(viewModel.additionalButtons) { button in
                        
                        Button(action: {
                            
                            button.action()
                            
                        }) {
                            
                            switch button.type {
                             
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
        }
        .padding(.leading, 14)
        .padding(.trailing, 15)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.bordersDivider, lineWidth: 1)
        )
    }
}

extension SearchBarComponent {
    
    struct ViewModelAction {
        
        struct ChangeState: Action {
            
            let state: ViewModel.State
        }
        
        struct ClearTextField: Action {}
    }
}

struct SearchBarComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            SearchBarComponent(viewModel: .init(placeHolder: .contacts))
                .previewLayout(.fixed(width: 375, height: 100))
            
            SearchBarComponent(viewModel: .init(state: .default, additionalButtons: [], placeHolder: .contacts, textColor: .textPlaceholder))
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}
