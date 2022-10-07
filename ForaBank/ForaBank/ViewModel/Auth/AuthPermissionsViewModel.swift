//
//  AuthPermissionsViewModel.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 07.02.2022.
//

import Foundation
import SwiftUI
import Combine

class AuthPermissionsViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var sensorType: BiometricSensorType
    @Published var header: HeaderViewModel
    @Published var buttons: [ButtonViewModel]
    
    private let dismissAction: () -> Void
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(_ model: Model, sensorType: BiometricSensorType, dismissAction: @escaping () -> Void) {
  
        self.sensorType = sensorType
        self.buttons = []
        self.header = .init(sensorType: sensorType)
        self.dismissAction = dismissAction
        self.model = model
        
        setupButtons(with: sensorType)
        bind()
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as AuthPermissionsViewModelAction.Confirm:
                    model.action.send(ModelAction.Auth.Sensor.Settings.allow)
                    
                case _ as AuthPermissionsViewModelAction.Skip:
                    model.action.send(ModelAction.Auth.Sensor.Settings.desideLater)
                
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func setupButtons(with sensor: BiometricSensorType) {
        
        switch sensor {
        case .touch:
            buttons = [ButtonViewModel(title: "Использовать отпечаток", style: .accept,
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Confirm(sensorType: .touch))
            }),
                       ButtonViewModel(title: "Пропустить", style: .skip,
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Skip())
            })]
            
        case .face:
            buttons = [ButtonViewModel(title: "Использовать Face ID", style: .accept,
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Confirm(sensorType: .face))
            }),
                       ButtonViewModel(title: "Пропустить", style: .skip,
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Skip())
            })]
        }
    }
}

extension AuthPermissionsViewModel {
    
    struct HeaderViewModel {
        
        var title: String
        var icon: Image
        
        init(sensorType: BiometricSensorType) {
            
            switch sensorType {
            case .touch:
                title = "Вместо  пароля вы можете использовать отпечаток для входа"
                icon = .ic64TouchID
                
            case .face:
                title = "Вместо  пароля вы можете использовать Face ID для входа"
                icon = .ic64FaceId
            }
        }
    }

    struct ButtonViewModel: Identifiable, Hashable {
    
        let id = UUID()
        var title: String
        var style: Style
        var action: () -> Void
        
        enum Style {
            
            case accept
            case skip
            
            var background: Color {
                
                switch self{
                    
                case .accept:
                    return Color.buttonPrimary
                case .skip:
                    return Color.buttonSecondary
                }
            }
            
            var textColor: Color{
                
                switch self{
                    
                case .accept:
                    return Color.textWhite
                case .skip:
                    return Color.textSecondary
                }
            }
        }
        
        static func == (lhs: AuthPermissionsViewModel.ButtonViewModel, rhs: AuthPermissionsViewModel.ButtonViewModel) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
               hasher.combine(id)
           }
    }
}

enum AuthPermissionsViewModelAction {
    
    struct Confirm: Action {
        
        let sensorType: BiometricSensorType
    }
    
    struct Skip: Action { }
}
