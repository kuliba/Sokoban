//
//  GetShowcaseDomain+State.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

extension GetShowcaseDomain {
    
    public struct State: Equatable {
        
        var isLoading = false
        var result: Result?
        var selected: String?

        public init(isLoading: Bool = false, result: Result? = nil, selected: String? = nil) {
            self.isLoading = isLoading
            self.result = result
            self.selected = selected
        }
    }
}

public extension GetShowcaseDomain.State {
    
    var showcase: GetShowcaseDomain.ShowCase? {
        
        guard case let .success(showcase) = result
        else { return nil }
        
        return showcase
    }
}
