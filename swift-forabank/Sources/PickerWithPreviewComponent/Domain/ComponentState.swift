//
//  ComponentState.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

import Foundation

public enum ComponentState: Equatable {
    
    case monthly(SelectionWithOptions)
    case yearly(SelectionWithOptions)
    
    public struct SelectionWithOptions: Equatable {
        
        public let selection: OptionWithMapImage
        public let options: [OptionWithMapImage]
        
        public init(selection: OptionWithMapImage, options: [OptionWithMapImage]) {
            
            self.selection = selection
            self.options = options
        }
    }
    
    public var subscriptionType: SubscriptionType {
        
        switch self {
        case .monthly: return .monthly
        case .yearly:  return .yearly
        }
    }
    
    public var selectionOption: OptionWithMapImage {
        
        switch self {
        case let .monthly(selectionWithOptions):
            
            return selectionWithOptions.selection
            
        case let .yearly(selectionWithOptions):
            
            return selectionWithOptions.selection
        }
    }

    public var image: MapImage {
        
        switch self {
        case let .monthly(selectionWithOptions),
            let .yearly(selectionWithOptions):
            
            return selectionWithOptions.selection.mapImage
        }
    }
}

public enum SubscriptionType: String, CaseIterable, Identifiable, Equatable {
    
    case monthly = "Месячная"
    case yearly =  "Годовая"
    
    public var id: Self { self }
}
