//
//  HideTabBarModifier.swift
//  ForaBank
//
//  Created by Max Gribov on 28.06.2022.
//

import SwiftUI

struct HideTabBarModifier: ViewModifier {
    
    @Binding var isHidden: Bool
    @State private var tabBarController: UITabBarController?
    @State private var tabBarFrame: CGRect?

    func body(content: Content) -> some View {
        
        content
            .introspectTabBarController(customize: { tabBarController in
                
                self.tabBarController = tabBarController
                
                let oldFrame = tabBarController.view.frame
                let newFrame = CGRect(
                    x: 0,
                    y: 0,
                    width: oldFrame.width,
                    height: oldFrame.height + tabBarController.view.safeAreaInsets.bottom
                )
                tabBarFrame = newFrame
            })
            .onChange(of: isHidden, perform: { newValue in
                
                guard let tabBarController, let tabBarFrame else {
                    return
                }
                
                tabBarController.tabBar.isHidden = newValue
                tabBarController.view.frame = tabBarFrame

                UIView.transition(with: tabBarController.view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
            })
    }
}

extension View {
    
    func tabBar(isHidden: Binding<Bool>) -> some View {
        
        modifier(HideTabBarModifier(isHidden: isHidden))
    }
}
