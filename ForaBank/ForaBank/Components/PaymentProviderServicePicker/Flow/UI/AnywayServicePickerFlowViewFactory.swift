//
//  AnywayServicePickerFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import SwiftUI

struct AnywayServicePickerFlowViewFactory<AnywayFlowView>
where AnywayFlowView: View {
    
    let makeAnywayFlowView: MakeAnywayFlowView
    let makeIconView: IconDomain.MakeIconView
}

extension AnywayServicePickerFlowViewFactory {
    
    typealias MakeAnywayFlowView = (AnywayFlowModel) -> AnywayFlowView
}
