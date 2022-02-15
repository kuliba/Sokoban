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
    
    private let model: Model
    
    @Published var sensorType: SensorType
    @Published var header: HeaderViewModel
    @Published var buttons: [ButtonViewModel]
    
    init(_ model: Model) {
        
        self.model = model
        
        sensorType = .touchID
        buttons = []
        header = .init(sensorType: .touchID)
        
        sensorType = getSensorType()
        
        switch sensorType {
        case .touchID:
            header = .init(sensorType: sensorType)
            buttons = [ButtonViewModel(title: "Использовать отпечаток", style: .accept,
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Confirm())
            }),
                       ButtonViewModel(title: "Пропустить", style: .skip,
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Skip())
            })]
            
        case .faceID:
            header = .init(sensorType: sensorType)
            buttons = [ButtonViewModel(title: "Использовать Face ID", style: .accept,
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Confirm())
            }),
                       ButtonViewModel(title: "Пропустить", style: .skip,
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Skip())
            })]
        }
    }
    
    func getSensorType() -> SensorType {
        .faceID
    }
    
}

extension AuthPermissionsViewModel {
    
    enum SensorType {
        
        case touchID
        case faceID
    }
    
    struct HeaderViewModel {
        
        var title: String
        var icon: Image
        
        init(sensorType: SensorType) {
            
            switch sensorType {
            case .touchID:
                title = "Вместо  пароля вы можете использовать отпечаток для входа"
                icon = .ic64TouchID
            case .faceID:
                title = "Вместо  пароля вы можете использовать Face ID для входа"
                icon = .ic64FaceId
            }
        }
    }

    struct ButtonViewModel: Identifiable, Hashable {
        
        static func == (lhs: AuthPermissionsViewModel.ButtonViewModel, rhs: AuthPermissionsViewModel.ButtonViewModel) -> Bool {
            return lhs.title == rhs.title
        }
        
        func hash(into hasher: inout Hasher) {
               hasher.combine(title)
           }
        
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
    }
}

enum AuthPermissionsViewModelAction {
    
    struct Confirm: Action { }
    struct Skip: Action { }
}
