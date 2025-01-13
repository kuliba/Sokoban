//
//  CardGuardianConfigTests.swift
//
//
//  Created by Andryusina Nataly on 09.02.2024.
//

import XCTest
import SwiftUI
@testable import CardGuardianUI

final class CardGuardianConfigTests: XCTestCase {
    
    typealias Config = CardGuardian.Config
    
    //MARK: - test init config
    
    func test_init_config_shouldSetAllValues() {
        
        let config: Config = .init(
            images: .init(
                toggleLock: .lock,
                changePin: .changePin,
                showOnMain: .showOnMain),
            paddings: .init(
                leading: 1,
                trailing: 2,
                vertical: 3,
                subtitleLeading: 4),
            sizes: .init(
                buttonHeight: 5,
                icon: 6),
            colors: .init(
                foreground: .white,
                subtitle: .black),
            fonts: .init(
                title: .body,
                subtitle: .footnote))
        
        XCTAssertNoDiff(config.images.changePin, .changePin)
        XCTAssertNoDiff(config.images.toggleLock, .lock)
        XCTAssertNoDiff(config.images.showOnMain, .showOnMain)
        
        XCTAssertNoDiff(config.paddings.leading, 1)
        XCTAssertNoDiff(config.paddings.trailing, 2)
        XCTAssertNoDiff(config.paddings.vertical, 3)
        XCTAssertNoDiff(config.paddings.subtitleLeading, 4)

        XCTAssertNoDiff(config.sizes.buttonHeight, 5)
        XCTAssertNoDiff(config.sizes.icon, 6)
        
        XCTAssertNoDiff(config.colors.foreground, .white)
        XCTAssertNoDiff(config.colors.subtitle, .black)

        XCTAssertNoDiff(config.fonts.title, .body)
        XCTAssertNoDiff(config.fonts.subtitle, .footnote)
    }
    
    // MARK: - test imageByType
    
    func test_imageByType() {
        
        let images: Config.Images = .init(
            toggleLock: .lock,
            changePin: .changePin,
            showOnMain: .showOnMain
        )
        
        XCTAssertNoDiff(images.imageByType(.changePin), .changePin)
        XCTAssertNoDiff(images.imageByType(.toggleLock), .lock)
        XCTAssertNoDiff(images.imageByType(.showOnMain), .showOnMain)
    }
}

private extension Image {
    
    static let lock: Self = Image(systemName: "lock")
    static let changePin: Self = Image(systemName: "pin")
    static let showOnMain: Self = Image(systemName: "eye")
}
