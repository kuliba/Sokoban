//
//  SplashScreenRootViewModelFactoryTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 16.03.2025.
//

import SplashScreenUI
@testable import Vortex
import XCTest

class SplashScreenRootViewModelFactoryTests: RootViewModelFactoryTests {
    
    func makeCodableSplashScreenStorage(
        entries: [String: CodableSplashScreenStorage.Entry]
    ) -> CodableSplashScreenStorage {
        
        return .init(entries: entries)
    }
    
    func makeEntry(
        items: [CodableSplashScreenSettings],
        serial: String = anyMessage()
    ) -> CodableSplashScreenStorage.Entry {
        
        return .init(items: items, serial: serial)
    }
    
    func makeCodableSplashScreenSettings(
        logo: CodableSplashScreenSettings.Logo? = nil,
        text: CodableSplashScreenSettings.Text? = nil,
        subtext: CodableSplashScreenSettings.Text? = nil,
        footer: CodableSplashScreenSettings.Logo? = nil,
        imageData: CodableSplashScreenSettings.ImageData? = nil,
        link: String = anyMessage(),
        period: String = anyMessage()
    ) throws -> CodableSplashScreenSettings {
        
        let data = try sampleImageData()
        
        return .init(
            logo: logo ?? makeLogo(),
            text: text ?? makeText(),
            subtext: subtext,
            footer: footer ?? makeLogo(),
            imageData: imageData ?? .data(data),
            link: link,
            period: period
        )
    }
    
    func sampleImageData(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let image = UIImage.make(withColor: .red)
        return try XCTUnwrap(image.pngData())
    }
    
    func makeLogo(
        color: String = anyMessage(),
        shadow: CodableSplashScreenSettings.Shadow? = nil
    ) -> CodableSplashScreenSettings.Logo {
        
        return .init(color: color, shadow: shadow ?? makeShadow())
    }
    
    func makeText(
        color: String = anyMessage(),
        size: CGFloat = .random(in: 1..<100),
        value: String = anyMessage(),
        shadow: CodableSplashScreenSettings.Shadow? = nil
    ) -> CodableSplashScreenSettings.Text {
        
        return .init(color: color, size: size, value: value, shadow: shadow ?? makeShadow())
    }
    
    func makeShadow(
        color: String = anyMessage(),
        opacity: Double = .random(in: 1..<100),
        radius: CGFloat = .random(in: 1..<100),
        x: CGFloat = .random(in: 1..<100),
        y: CGFloat = .random(in: 1..<100)
    ) -> CodableSplashScreenSettings.Shadow {
        
        return .init(color: color, opacity: opacity, radius: radius, x: x, y: y)
    }
}
