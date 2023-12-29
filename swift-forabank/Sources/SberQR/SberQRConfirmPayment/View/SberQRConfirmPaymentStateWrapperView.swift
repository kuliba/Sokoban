//
//  SberQRConfirmPaymentStateWrapperView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import PaymentComponents
import SwiftUI

struct SberQRConfirmPaymentStateWrapperView: View {
    
    public typealias Map = (GetSberQRDataResponse.Parameter.Info) -> Info
    
    @StateObject private var viewModel: SberQRConfirmPaymentViewModel
    
    private let map: Map
    private let config: Config
    
    public init(
        viewModel: SberQRConfirmPaymentViewModel,
        map: @escaping Map,
        config: Config
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.map = map
        self.config = config
    }
    
    var body: some View {
        
        SberQRConfirmPaymentWrapperView(
            viewModel: viewModel,
            map: map,
            config: config
        )
    }
}

// MARK: - Previews

struct SberQRConfirmPaymentStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            SberQRConfirmPaymentStateWrapperView(
                viewModel: .preview(
                    initialState: .fixedAmount(.preview)
                ),
                map: Info.preview,
                config: .preview
            )
            
            SberQRConfirmPaymentStateWrapperView(
                viewModel: .preview(
                    initialState: .editableAmount(.preview)
                ),
                map: Info.preview,
                config: .preview
            )
        }
    }
}
