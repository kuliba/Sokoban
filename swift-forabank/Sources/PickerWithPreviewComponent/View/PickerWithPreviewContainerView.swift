//
//  PickerWithPreviewContainerView.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

import SwiftUI

public struct PickerWithPreviewContainerView: View {
    
    public typealias ViewModel = PickerWithPreviewModel
    
    @ObservedObject private var model: ViewModel
    
    public let viewConfig: ViewConfig
    
    public let checkUncheckImage: CheckUncheckImages
    
    public let paymentAction: () -> Void
    public let continueAction: () -> Void
    
    public init(
        model: ViewModel,
        viewConfig: ViewConfig,
        checkUncheckImage: CheckUncheckImages,
        paymentAction: @escaping () -> Void,
        continueAction: @escaping () -> Void
    ) {
        
        self.model = model
        self.viewConfig = viewConfig
        self.checkUncheckImage = checkUncheckImage
        self.paymentAction = paymentAction
        self.continueAction = continueAction
    }
    
    public var body: some View {
        
        PickerWithPreviewView(
            state: model.state, //get
            send: model.send,   //set
            paymentAction: paymentAction,
            continueAction: continueAction,
            checkUncheckImage: checkUncheckImage,
            viewConfig: viewConfig
        )
        .animation(.default, value: model.state)
    }
}
