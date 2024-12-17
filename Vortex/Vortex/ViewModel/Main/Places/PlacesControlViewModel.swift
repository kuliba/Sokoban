//
//  PlacesControlViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 06.04.2022.
//

import Foundation
import Combine
import SwiftUI

class PlacesControlViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var mode: Mode
    @Published var optionButtons: [OptionButtonViewModel]
    @Published var modeButton: ModeButtonViewModel
    
    private var bindings = Set<AnyCancellable>()
    
    init(mode: Mode, optionButtons: [OptionButtonViewModel], modeButton: ModeButtonViewModel) {
        
        self.mode = mode
        self.optionButtons = optionButtons
        self.modeButton = modeButton
    }
    
    init(mode: Mode) {
        
        self.mode = mode
        self.optionButtons = []
        self.modeButton = ModeButtonViewModel(mode: mode, action: {})
        
        optionButtons = [OptionButtonViewModel(type: .filter, action: {[weak self] in self?.action.send(PlacesControlViewModelAction.FilterDidTapped())})]
        modeButton = modeButtonViewModel()
        bind()
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PlacesControlViewModelAction.ToggleMode:
                    switch mode {
                    case .map:
                        mode = .list
                    
                    case .list:
                        mode = .map
                    }
                    withAnimation {
                        modeButton = modeButtonViewModel()
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func modeButtonViewModel() -> ModeButtonViewModel {
        
        ModeButtonViewModel(mode: mode, action: {[weak self] in self?.action.send(PlacesControlViewModelAction.ToggleMode())})
    }
}

//MARK: - Types

extension PlacesControlViewModel {
    
    enum Mode {
        
        case map
        case list
    }
    
    struct ModeButtonViewModel {

        let icon: Image
        let title: String
        let action: () -> Void
        
        internal init(icon: Image, title: String, action: @escaping () -> Void) {
            
            self.icon = icon
            self.title = title
            self.action = action
        }
        
        init(mode: Mode, action: @escaping () -> Void) {
            
            switch mode {
            case .map:
                self.icon = .ic24List
                self.title = "Список"
                
                
            case .list:
                self.icon = .ic24Map
                self.title = "Карта"
            }
            
            self.action = action
        }
    }
    
    struct OptionButtonViewModel: Identifiable {
        
        let id = UUID()
        let type: Kind
        let action: () -> Void
        
        var icon: Image {
            
            switch type {
            case .location: return .ic24MapPin
            case .metro: return .ic24Metro
            case .filter: return .ic24Sliders
            }
        }
        
        enum Kind: CaseIterable {
            
            case location
            case metro
            case filter
        }
    }
}

//MARK: - Action

enum PlacesControlViewModelAction {
    
    struct ToggleMode: Action {}
    
    struct FilterDidTapped: Action {}
}
