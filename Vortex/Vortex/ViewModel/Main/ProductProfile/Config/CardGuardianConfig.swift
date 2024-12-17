//
//  CardGuardianConfig.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 01.02.2024.
//

import SwiftUI
import CardGuardianUI

extension CardGuardian.Config {
    
    static func `default`(
        isLock: Bool,
        isOnMain: Bool
    ) -> Self {
        .init(
            images: Images.default(isLock: isLock, isOnMain: isOnMain),
            paddings: .default,
            sizes: .default,
            colors: .default,
            fonts: .default
        )
    }
}

private extension CardGuardian.Config.Colors {
    
    static let `default`: Self = .init(
        foreground: .textSecondary,
        subtitle: .textPlaceholder)
}

private extension CardGuardian.Config.Images {
    
    static func `default`(
        isLock: Bool,
        isOnMain: Bool
    ) -> Self {
        .init(
            toggleLock: imageToggleLock(isLock),
            changePin: .ic24Pass,
            showOnMain: imageOnMain(isOnMain)
        )
    }
    
    static func imageToggleLock(
        _ isLock: Bool
    ) -> Image {
        isLock ? .ic24Unlock : .ic24Lock
    }
    
    static func imageOnMain(
        _ onMain: Bool
    ) -> Image {
        onMain ? .ic24EyeOff : .ic24Eye
    }
}

private extension CardGuardian.Config.Paddings {
    
    static let `default`: Self = .init(
        leading: 20,
        trailing: 80,
        vertical: 8,
        subtitleLeading: 56)
}

private extension CardGuardian.Config.Sizes {
    
    static let `default`: Self = .init(buttonHeight: 40, icon: 24)
}

private extension CardGuardian.Config.Fonts {
    
    static let `default`: Self = .init(
        title: .textH4M16240(),
        subtitle: .textBodyMR14200())
}
