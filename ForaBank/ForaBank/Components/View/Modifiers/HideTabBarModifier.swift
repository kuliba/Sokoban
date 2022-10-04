//
//  HideTabBarModifier.swift
//  ForaBank
//
//  Created by Max Gribov on 28.06.2022.
//

import SwiftUI
import Introspect

struct HideTabBarModifier: ViewModifier {
    
    @Binding var isHidden: Bool
    @State private var tabBarController: UITabBarController?
    
    func body(content: Content) -> some View {
        
        content
            .introspectTabBarController(customize: { tabBarController in
                
                self.tabBarController = tabBarController
                
            })
            .onChange(of: isHidden, perform: { newValue in
                
                guard let tabBarController = tabBarController else {
                    return
                }
                
                tabBarController.tabBar.isHidden = newValue
                UIView.transition(with: tabBarController.view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
            })
    }
}

extension View {
    
    func tabBar(isHidden: Binding<Bool>) -> some View {
        
        modifier(HideTabBarModifier(isHidden: isHidden))
    }
}
