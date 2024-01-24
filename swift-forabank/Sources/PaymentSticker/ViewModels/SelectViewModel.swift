//
//  SelectViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public struct SelectViewModel {
    
    public typealias ParameterSelect = Operation.Parameter.Select
    public typealias OptionID = ParameterSelect.State.OptionsListViewModel.OptionViewModel
    
    let parameter: ParameterSelect
    let isSearching: Bool
    let tapAction: () -> Void
    let select: (OptionID) -> Void
    let search: (String) -> Void
    
    public init(
        parameter: SelectViewModel.ParameterSelect,
        isSearching: Bool,
        tapAction: @escaping () -> Void,
        select: @escaping (SelectViewModel.OptionID) -> Void,
        search: @escaping (String) -> Void
    ) {
        self.parameter = parameter
        self.isSearching = isSearching
        self.tapAction = tapAction
        self.select = select
        self.search = search
    }
    
    public enum TapAction {
        
        case chevronButtonTapped
        case openBranch
    }
}

//MARK: Helper

extension SelectViewModel {
    
    var icon: ImageData {
       
        switch parameter.id {
        case .citySelector:
            return .named("ic24MapPin")
        case .officeSelector:
            return .named("ic24Bank")
        default:
            return .named("ic24ArrowDownCircle")
        }
    }
}

extension SelectViewModel {
    
    public init(
        parameter: Operation.Parameter.Select,
        tapAction: @escaping () -> Void,
        select: @escaping (SelectViewModel.OptionID) -> Void,
        search: @escaping (String) -> Void
    ) {
       
        self.parameter = parameter
        self.isSearching = parameter.id == .citySelector ? true : false
        self.tapAction = tapAction
        self.select = select
        self.search = search
    }
}
