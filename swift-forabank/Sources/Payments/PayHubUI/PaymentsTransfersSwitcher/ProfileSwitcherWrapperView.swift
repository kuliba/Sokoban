//
//  ProfileSwitcherWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.08.2024.
//

import SwiftUI

public struct ProfileSwitcherWrapperView<Corporate, Personal, ProfileView>: View
where ProfileView: View {
    
    @ObservedObject private var model: Model
    
    private let profileView: (State) -> ProfileView
    
    public init(
        model: Model,
        @ViewBuilder profileView: @escaping (State) -> ProfileView
    ) {
        self.model = model
        self.profileView = profileView
    }
    
    public var body: some View {
        
        profileView(model.state)
    }
}

public extension ProfileSwitcherWrapperView {
    
    typealias Model = ProfileSwitcherModel<Corporate, Personal>
    typealias State = ProfileState<Corporate, Personal>?
}
