//
//  QRSearchCityViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.12.2022.
//

import Combine
import Foundation
import TextFieldComponent

enum RegionsState: Equatable {
    
    typealias Region = String
    
    case all([Region])
    case filtered([Region])
}

class QRSearchCityViewModel: ObservableObject, Identifiable {
    
    @Published private(set) var state: RegionsState
    
    let id = UUID().uuidString
    let title = "Выберите регион"
    let select: (String) -> Void
    
    let searchViewModel: SearchBarView.ViewModel
    
    internal init(
        regions: [RegionsState.Region],
        searchViewModel: SearchBarView.ViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain(),
        select: @escaping (String) -> Void
    ) {
        self.state = .all(regions)
        self.searchViewModel = searchViewModel
        self.select = select
        
        searchViewModel.textFieldModel.textPublisher
            .debounce(for: .milliseconds(299), scheduler: scheduler)
            .removeDuplicates()
            .map { [regions] in regions.reduce(with: $0) }
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension Array where Element == RegionsState.Region {
    
    func reduce(with text: String?) -> RegionsState {
        
        guard let text, !text.isEmpty else {
            return .all(self)
        }
        
        let filtered = filter {
            $0.localizedLowercase.prefix(text.count) == text.localizedLowercase
        }
        return .filtered(filtered)
    }
}
