//
//  PlainClientInformBottomSheetViewModel.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 10.10.2024.
//

import SwiftUI

class PlainClientInformBottomSheetViewModel: ObservableObject {
    
    @Published var isShowNavBar = false
    @Published var shouldScroll = true
    var axes: Axis.Set { return shouldScroll ? .vertical : [] }
    
    let info: InfoModel
    
    init(isShowNavBar: Bool = false, shouldScroll: Bool, info: InfoModel) {
        self.isShowNavBar = isShowNavBar
        self.shouldScroll = shouldScroll
        self.info = info
    }
}
