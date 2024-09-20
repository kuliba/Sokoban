//
//  View+onFirstAppear.swift
//
//
//  Created by Igor Malyarov on 16.07.2024.
//

#if canImport(SwiftUI)
import SwiftUI

public extension View {
    
    func onFirstAppear(
        _ action: @escaping () -> Void
    ) -> some View {
        
        modifier(OnFirstAppearModifier(action))
    }
}

struct OnFirstAppearModifier: ViewModifier {
    
    @State private var didAppeared = false
    private let action: () -> Void
    
    init(
        _ action: @escaping () -> Void
    ) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !didAppeared else { return }
                didAppeared = true
                action()
            }
    }
}
#endif
