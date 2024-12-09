//
//  EnvironmentKey.swift
//  Vortex
//
//  Created by Dmitry Martynov on 17.04.2023.
//

import SwiftUI

private struct MainViewSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var mainViewSize: CGSize {
        get { self[MainViewSizeKey.self] }
        set { self[MainViewSizeKey.self] = newValue }
    }
}

