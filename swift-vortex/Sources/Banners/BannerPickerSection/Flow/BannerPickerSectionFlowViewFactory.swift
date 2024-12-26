//
//  BannerPickerSectionFlowViewFactory.swift
//  
//
//  Created by Andryusina Nataly on 08.09.2024.
//

import PayHub
import SwiftUI

public struct BannerPickerSectionFlowViewFactory<ContentView, DestinationView, SelectedBanner, BannerList> {
    
    let makeContentView: MakeContentView
    let makeDestinationView: MakeDestinationView
    
    public init(
        makeContentView: @escaping MakeContentView,
        makeDestinationView: @escaping MakeDestinationView
    ) {
        self.makeContentView = makeContentView
        self.makeDestinationView = makeDestinationView
    }
}

public extension BannerPickerSectionFlowViewFactory {
    
    typealias MakeContentView = () -> ContentView
    
    typealias Destination = BannerPickerSectionFlowState<SelectedBanner, BannerList>.Destination
    typealias MakeDestinationView = (Destination) -> DestinationView
}
