//
//  PaymentsTransfersToolbarContentViewFactory.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import SwiftUI

public struct PaymentsTransfersToolbarContentViewFactory<ProfileLabel, QRLabel> {
    
    public let makeProfileLabel: MakeProfileLabel
    public let makeQRLabel: MakeQRLabel
    
    public init(
        @ViewBuilder makeProfileLabel: @escaping MakeProfileLabel,
        @ViewBuilder makeQRLabel: @escaping MakeQRLabel
    ) {
        self.makeProfileLabel = makeProfileLabel
        self.makeQRLabel = makeQRLabel
    }
}

public extension PaymentsTransfersToolbarContentViewFactory {
    
    typealias MakeProfileLabel = () -> ProfileLabel
    typealias MakeQRLabel = () -> QRLabel
}
