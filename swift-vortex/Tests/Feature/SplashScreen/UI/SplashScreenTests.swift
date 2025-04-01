//
//  SplashScreenTests.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SplashScreenUI
import SwiftUI
import XCTest

class SplashScreenTests: XCTestCase {
    
    typealias State = SplashScreenState
    typealias Event = SplashScreenEvent
    typealias Effect = SplashScreenEffect

    func makeSettings(
        duration: TimeInterval = .random(in: 1...100),
        image: Image = .init(systemName: "star"),
        logo: State.Settings.Logo? = nil,
        text: State.Settings.Text? = nil,
        subtext: State.Settings.Text? = nil,
        footer: State.Settings.Logo? = nil
    ) -> State.Settings {
        
        return .init(
            duration: duration,
            image: image,
            logo: logo ?? makeLogo(),
            text: text ?? makeText(),
            subtext: subtext,
            footer: footer ?? makeLogo()
        )
    }
    
    func makeLogo(
        color: Color = .red,
        shadow: SplashScreenState.Settings.Shadow? = nil
    ) -> State.Settings.Logo {
        
        return .init(color: color, shadow: shadow ?? makeShadow())
    }
    
    func makeText(
        color: Color = .primary,
        size: CGFloat = .random(in: 1..<100),
        value: String = anyMessage(),
        shadow: SplashScreenState.Settings.Shadow? = nil
    ) -> State.Settings.Text {
        
        return .init(
            color: color,
            size: size,
            value: value,
            shadow: shadow ?? makeShadow()
        )
    }
    
    func makeShadow(
        color: Color = .primary,
        opacity: Double = .random(in: 1..<100),
        radius: CGFloat = .random(in: 1..<100),
        x: CGFloat = .random(in: 1..<100),
        y: CGFloat = .random(in: 1..<100)
    ) -> State.Settings.Shadow {
        
        return .init(color: color, opacity: opacity, radius: radius, x: x, y: y)
    }
}
