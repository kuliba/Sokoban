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
    let icon: ImageData
    let tapAction: () -> Void
    let select: (OptionID) -> Void
    
    public init(
        parameter: SelectViewModel.ParameterSelect,
        icon: ImageData,
        tapAction: @escaping () -> Void,
        select: @escaping (SelectViewModel.OptionID) -> Void
    ) {
        self.parameter = parameter
        self.icon = icon
        self.tapAction = tapAction
        self.select = select
    }
    
    public enum TapAction {
        
        case chevronButtonTapped
        case openBranch
    }
}
