//
//  ComposedPaymentsTransfersToolbarViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.08.2024.
//

struct ComposedPaymentsTransfersToolbarViewFactory<ProfileLabel> {
    
    let makeProfileLabel: MakeProfileLabel
}

extension ComposedPaymentsTransfersToolbarViewFactory {
 
   typealias MakeProfileLabel = () -> ProfileLabel
}
