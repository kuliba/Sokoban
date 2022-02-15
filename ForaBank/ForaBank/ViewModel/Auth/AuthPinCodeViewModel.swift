//
//  AuthPinCodeViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 10.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthPinCodeViewModel: ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()
    
    let pinCode: PinCodeViewModel
    @Published var numpad: NumPadViewModel
    @Published var footer: FooterViewModel
    
    private let model: Model
    private var mode: CurrentValueSubject<Mode, Never>
    private var bindings = Set<AnyCancellable>()

    init(pinCode: PinCodeViewModel, numpad: NumPadViewModel, footer: FooterViewModel, model: Model = .emptyMock, mode: Mode = .lock) {
        
        self.pinCode = pinCode
        self.numpad = numpad
        self.footer = footer
        self.model = model
        self.mode = .init(mode)
    }
    
    init(_ model: Model, mode: Mode) {
 
        switch mode {
        case .lock:
            self.pinCode = PinCodeViewModel(title: "Введите код", pincodeLength: model.pincodeLength)
            //TODO: detect sensor
            self.numpad = NumPadViewModel(leftButton: .init(type: .text("Выход"), action: .exit), rightButton: .init(type: .icon(.ic40FaceId), action: .sensor))
            self.footer = FooterViewModel(continueButton: nil, cancelButton: nil)
            self.mode = .init(.lock)
            
        case .create:
            self.pinCode = PinCodeViewModel(title: "Придумайте код", pincodeLength: model.pincodeLength)
            self.numpad = NumPadViewModel(leftButton: .init(type: .empty, action: .cancel), rightButton: .init(type: .icon(.ic40Delete), action: .delete))
            self.footer = FooterViewModel(continueButton: nil, cancelButton: nil)
            self.mode = .init(.create(.fist))
        }
        
        self.model = model
        
        bind()
    }
    
    func bind() {
        
        
    }
    
    func bindNumpad() {
        
        numpad.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as NumPadViewModelAction.Button:
                    switch payload {
                    case .digit(let number):
                        pinCode.pincode = pinCode.pincode + String(number)
                    
                    case .delete:
                        guard pinCode.pincode.count > 0 else {
                            return
                        }
                        pinCode.pincode = String(pinCode.pincode.dropLast())
                        
                    case .sensor:
                        print("activate sensor")
                        
                    case .cancel:
                        print("cancel action")
                        
                    case .exit:
                        print("exit action")
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Types

extension AuthPinCodeViewModel {
    
    enum Mode {
        
        // lock screen mode
        case lock
        
        // create pincode mode
        case create(Stage)
        
        enum Stage {
            
            // entering first time pincode
            case fist
            
            // entering second time pincode
            case second(String)
        }
    }
}

//MARK: - PinCodeViewModel

extension AuthPinCodeViewModel {
    
    class PinCodeViewModel: ObservableObject {

        @Published var title: String = "Придумайте код"
        @Published var pincode: String
        @Published var dots: [DotViewModel]
        @Published var state: State
        
        private let pincodeLength: Int
        
        init(title: String, pincodeLength: Int, pincode: String = "", state: State = .editing) {
            
            self.title = title
            self.pincode = pincode
            self.dots = Self.dots(pincode: pincode, length: pincodeLength)
            self.state = state
            self.pincodeLength = pincodeLength
        }
        
        static func dots(pincode: String, length: Int) -> [DotViewModel] {
            
            return (0..<length).map{ pincode.count > $0 ? .filled : .empty }
        }
        
        enum State {

            case editing
            case incorrect
            case correct
        }
        
        enum DotViewModel {
            
            case empty
            case filled
        }
    }
}

//MARK: - NumPadViewModel

extension AuthPinCodeViewModel {
    
    class NumPadViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var buttons: [[ButtonViewModel]]
        
        init(buttons: [[ButtonViewModel]]) {
            
            self.buttons = buttons
        }
        
        init(leftButton: ButtonData, rightButton: ButtonData) {
            
            self.buttons = [[]]
            self.buttons =  [[.init(type: .digit("1"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(1)) }),
                              .init(type: .digit("2"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(2)) }),
                              .init(type: .digit("3"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(3)) })],
           
                             [.init(type: .digit("4"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(4)) }),
                              .init(type: .digit("5"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(5)) }),
                              .init(type: .digit("6"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(6)) })],

                             [.init(type: .digit("7"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(7)) }),
                              .init(type: .digit("8"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(8)) }),
                              .init(type: .digit("9"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(9)) })],
           
                             [.init(type: leftButton.type,
                                    action: { [weak self] in self?.action.send(leftButton.action) }),
                              .init(type: .digit("0"),
                                    action: { [weak self] in self?.action.send(NumPadViewModelAction.Button.digit(9)) }),
                              .init(type: rightButton.type,
                                    action: { [weak self] in self?.action.send(rightButton.action) })]]
        }
        
        struct ButtonData {
            
            let type: ButtonViewModel.Kind
            let action: NumPadViewModelAction.Button
        }
        
        struct ButtonViewModel: Identifiable, Hashable {

            let id = UUID()
            let type: Kind
            let action: () -> Void
            
            enum Kind {
                
                case digit(String)
                case icon(Image)
                case text(String)
                case empty
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(id)
            }
            
            static func == (lhs: ButtonViewModel, rhs: ButtonViewModel) -> Bool {
                
                return lhs.id == rhs.id
            }
        }
    }
    
    enum NumPadViewModelAction: Action {
        
        enum Button: Action {
            
            case digit(Int)
            case delete
            case sensor
            case cancel
            case exit
        }
    }
}

//MARK: - FooterViewModel

extension AuthPinCodeViewModel {
    
    class FooterViewModel: ObservableObject {
        
        @Published var continueButton: ButtonViewModel?
        @Published var cancelButton: ButtonViewModel?
        
        struct ButtonViewModel {
            
            let title: String
            let action: () -> Void
        }
        
        internal init(continueButton: ButtonViewModel?, cancelButton: ButtonViewModel?) {

            self.continueButton = continueButton
            self.cancelButton = cancelButton
        }
    }
}

//MARK: - Actions

enum AuthPinCodeViewModelAction {

    struct Cancel: Action {}
    
    struct Continue: Action {

        let code: String
    }
}
