//
//  SberQRConfirmPaymentWrapperView.swift
//  Vortex
//
//  Created by Andrew Kurdin on 04.02.2025.
//

import SberQR
import SwiftUI

typealias SberQRConfirmPaymentViewModel = SberQR.SberQRConfirmPaymentViewModel
typealias GetSberQRDataResponse = SberQR.GetSberQRDataResponse

struct SberQRConfirmPaymentWrapperView: View {
    
    @ObservedObject var viewModel: SberQRConfirmPaymentViewModel
    
    let map: Map
    let config: Config
    
    var body: some View {
        
        SberQR.SberQRConfirmPaymentWrapperView(
            viewModel: viewModel,
            map: map,
            config: config
        )
        .loader(isLoading: viewModel.state.isInflight)
    }
    
    typealias Map = SberQR.SberQRConfirmPaymentWrapperView.Map
    typealias Config = SberQR.Config
}
