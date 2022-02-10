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
            buttons = [ButtonViewModel(title: "Использовать отпечаток",
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Confirm())
            }),
                       ButtonViewModel(title: "Пропустить",
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Skip())
            })]

        case .faceID:
            header = .init(sensorType: sensorType)
            buttons = [ButtonViewModel(title: "Использовать Face ID",
                                       action: { [weak self] in
                self?.action.send(AuthPermissionsViewModelAction.Confirm())
            }),
                       ButtonViewModel(title: "Пропустить",
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

    struct ButtonViewModel {

        var title: String
        var action: () -> Void
    }
}

enum AuthPermissionsViewModelAction {

    struct Confirm: Action { }
    struct Skip: Action { }
}
