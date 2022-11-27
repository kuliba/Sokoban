//
//  QRSearchOperatorViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.11.2022.
//

import SwiftUI
import Combine

class QRSearchOperatorViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    let navigationBar: NavigationBarViewModel
    let textFieldPlaceholder: String
    @Published var isLinkActive: Bool = false
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    private let model: Model
    var operators: [OperatorGroupData.OperatorData]
    private var bindings = Set<AnyCancellable>()
    
    init(textFieldPlaceholder: String,navigationBar: NavigationBarViewModel, operators: [OperatorGroupData.OperatorData], model: Model) {
        self.textFieldPlaceholder = textFieldPlaceholder
        self.operators = operators
        self.navigationBar = navigationBar
        self.model = model
        guard let operatorsData = model.dictionaryAnywayOperators() else { return }
        self.operators = operatorsData
        bind()
    }
    
    func bind() {
    
    }
    
    enum Link {
        
        case serchRegion
    }
}

extension QRSearchOperatorViewModel {
    
    struct NavigationBarViewModel {
        
        let title = "Все регионы"
        let changeRegionButton: ChangeRegionButtonViewModel
        
        struct ChangeRegionButtonViewModel {
            let icon = Image.ic16ChevronDown
            let action: () -> Void
        }
        
        init(action: @escaping () -> Void) {
            
            self.changeRegionButton = ChangeRegionButtonViewModel(action: action)
        }
    }
}
