//
//  View+simulateOnAppear.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import SwiftUI
import XCTest

extension View {
    
    @discardableResult
    func simulateOnAppear(
        timeout: TimeInterval = 0.05
    ) -> UIHostingController<Self> {
        
        let hostingController = UIHostingController(rootView: self)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        _ = XCTWaiter().wait(for: [.init()], timeout: timeout)
        
        return hostingController
    }
}
