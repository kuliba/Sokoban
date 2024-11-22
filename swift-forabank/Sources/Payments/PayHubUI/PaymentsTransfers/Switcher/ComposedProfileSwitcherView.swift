//
//  ComposedProfileSwitcherView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.08.2024.
//

import SwiftUI

public struct ComposedProfileSwitcherView<Corporate, CorporateView, Personal, PersonalView, UndefinedView>: View
where CorporateView: View,
      PersonalView: View,
      UndefinedView: View {
    
    @ObservedObject private var model: Model

    private let corporateView: (Corporate) -> CorporateView
    private let personalView: (Personal) -> PersonalView
    private let undefinedView: () -> UndefinedView
    
    public init(
        model: Model,
        @ViewBuilder corporateView: @escaping (Corporate) -> CorporateView,
        @ViewBuilder personalView: @escaping (Personal) -> PersonalView,
        @ViewBuilder undefinedView: @escaping () -> UndefinedView
    ) {
        self.model = model
        self.corporateView = corporateView
        self.personalView = personalView
        self.undefinedView = undefinedView
    }
    
    public var body: some View {
        
        ProfileSwitcherWrapperView(
            model: model,
            profileView: {
                
                ProfileSwitcherView(
                    state: $0, 
                    corporateView: corporateView,
                    personalView: personalView,
                    undefinedView: undefinedView
                )
            }
        )
    }
}

public extension ComposedProfileSwitcherView {
    
    typealias Model = ProfileSwitcherModel<Corporate, Personal>
}

