//
//  PresentableState.swift
//  
//
//  Created by Igor Malyarov on 04.06.2023.
//

import SwiftUI

fileprivate typealias IconData = [String: String]
fileprivate typealias Model = ItemSelectModel<Country>
fileprivate typealias ViewModel = IconedItemSelectViewModel<Country, IconData>

fileprivate extension Model.State {
    
    var chevronImage: Image {

        switch self {
        case .collapsed,
                .selected(_, listState: .collapsed):
            return unimplemented("need to set up or down image")
            
        case .expanded(_),
                .selected(_, listState: .expanded):
            return unimplemented("need to set up or down image")
        }
    }
}

fileprivate extension ViewModel {
    
    // derived from state
    var presentableState: PresentableState {
        
        .init(icon: icon, title: presentableTitle, textField: textField, chevron: chevron, list: list)
    }
    
    private var icon: PresentableState.IconViewModel {
        
        switch state.selectState {
        case .collapsed, .expanded:
            return .placeholder
            
        case let .selected(country, _):
            if let image: Image = unimplemented("need a closure `image(for: country)`") {
                return .image(image)
            } else {
                return .placeholder
            }
        }
    }
    
    private var presentableTitle: String? {
        
        switch state.selectState {
        case .collapsed:
            return nil
            
        default:
            return title// unimplemented("need to set default title")
        }
    }
    
    private var chevron: PresentableState.ChevronViewModel {
        
        .init(
            image: state.selectState.chevronImage,
            action: { [weak self] in self?.send(.toggleListVisibility) }
        )
    }
    
    private var list: [PresentableState.CountryViewModel]? {
        
        let selectCountryAction: (Country) -> Void = { [weak self] in
            
            self?.send(.select($0))
        }
        
        switch state.selectState {
        case .collapsed, .selected(_, listState: .collapsed):
            return nil
            
        case let .expanded(countries):
            return [.showAll(action: { unimplemented("need to provide show all closure") })]
            + countries.map {
                .init(with: $0, action: selectCountryAction)
            }
            
        case let .selected(country, listState: .expanded):
            return [.init(with: country, action: selectCountryAction)]
        }
    }
    
    struct PresentableState {
        
        // Maps countries to country view models using images and actions.
        //do not forget to inject additional view model at the beginning to present show all button
        
        let icon: IconViewModel
        let title: String?
        let textField: any TextField
        let chevron: ChevronViewModel
        let list: [CountryViewModel]?
        
        enum IconViewModel {
            
            case placeholder
            case image(Image)
        }
        
        struct ChevronViewModel {
            
            let image: Image
            let action: () -> Void
        }
        
        struct CountryViewModel: Identifiable {
            
            let id: String
            let name: String
            let action: (Item) -> Void
        }
    }
}

fileprivate extension ViewModel.PresentableState.CountryViewModel {
    
    static func showAll(action: @escaping () -> Void) -> Self {
        
        self.init(id: UUID().uuidString, name: "Show all", action: { _ in action() })
    }
    
    init(
        with country: Country,
        action: @escaping (Country) -> Void
    ) {
        self.init(id: country.id, name: country.name, action: action)
    }
}
