//
//  ComposedPaymentsTransfersToolbarViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

struct ComposedPaymentsTransfersToolbarViewFactory<ProfileLabel, QRLabel> {
    
    let makeProfileLabel: MakeProfileLabel
    let makeQRLabel: MakeQRLabel
}

extension ComposedPaymentsTransfersToolbarViewFactory {
    
    typealias MakeProfileLabel = () -> ProfileLabel
    typealias MakeQRLabel = () -> QRLabel
}
