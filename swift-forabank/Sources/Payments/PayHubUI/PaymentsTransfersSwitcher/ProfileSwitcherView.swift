//
//  ProfileSwitcherView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.08.2024.
//

import SwiftUI

public struct ProfileSwitcherView<Corporate, CorporateView, Personal, PersonalView, UndefinedView>: View
where CorporateView: View,
      PersonalView: View,
      UndefinedView: View {
    
    private let state: State
    
    private let corporateView: (Corporate) -> CorporateView
    private let personalView: (Personal) -> PersonalView
    private let undefinedView: () -> UndefinedView
    
    public init(
        state: State,
        @ViewBuilder corporateView: @escaping (Corporate) -> CorporateView,
        @ViewBuilder personalView: @escaping (Personal) -> PersonalView,
        @ViewBuilder undefinedView: @escaping () -> UndefinedView
    ) {
        self.state = state
        self.corporateView = corporateView
        self.personalView = personalView
        self.undefinedView = undefinedView
    }
    
    public var body: some View {
        
        Group {
            
            switch state {
            case .none:
                undefinedView()
                
            case let .corporate(corporate):
                corporateView(corporate)
                
            case let .personal(personal):
                personalView(personal)
            }
        }
        .transition(.slide.combined(with: .opacity))
        .animation(.easeInOut, value: stateID)
    }
}

public extension ProfileSwitcherView {
    
    typealias State = ProfileState<Corporate, Personal>?
}

private extension ProfileSwitcherView {
    
    var stateID: ID {
        
        switch state {
        case .none:      return .undefined
        case .corporate: return .corporate
        case .personal:  return .personal
        }
    }
    
    enum ID: Hashable {
        
        case corporate, personal, undefined
    }
}
