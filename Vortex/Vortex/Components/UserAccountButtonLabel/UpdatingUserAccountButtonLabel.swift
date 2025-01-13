//
//  UpdatingUserAccountButtonLabel.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.12.2024.
//

import Combine
import SwiftUI

struct UserLabel: Equatable {
    
    let avatar: Image?
    let name: String
}

struct UpdatingUserAccountButtonLabel: View {
    
    typealias UserLabelPublisher = AnyPublisher<UserLabel, Never>
    
    @State private var label: UserLabel
    
    private let publisher: UserLabelPublisher
    private let config: UserAccountButtonLabelConfig
    
    init(
        label: UserLabel,
        publisher: UserLabelPublisher,
        config: UserAccountButtonLabelConfig
    ) {
        self.label = label
        self.publisher = publisher
        self.config = config
    }
    
    var body: some View {
        
        labelView()
            .onReceive(publisher) { label = $0 }
    }
}

extension UpdatingUserAccountButtonLabel {
    
    func labelView() -> some View {
        
        UserAccountButtonLabel(
            avatar: label.avatar,
            name: label.name,
            config: config
        )
    }
}
