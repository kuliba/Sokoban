//
//  PlainClientInformBottomSheetViewModel.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 10.10.2024.
//

import SwiftUI

@available(iOS 15, *)
public class PlainClientInformBottomSheetViewModel: ObservableObject {
    
    @Published var isShowNavBar = false
    @Published var shouldScroll = true
    var axes: Axis.Set { return shouldScroll ? .vertical : [] }
    
    let info: ClientInformDataState
    
    public init(isShowNavBar: Bool = false, info: ClientInformDataState) {
        self.isShowNavBar = isShowNavBar
        self.info = info
    }
}
