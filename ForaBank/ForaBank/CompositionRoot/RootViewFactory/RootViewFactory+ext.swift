//
//  RootViewFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import InfoComponent
import SberQR
import SwiftUI

extension RootViewFactory {
    
    init(with imageCache: ImageCache, getUImage: @escaping (Md5hash) -> UIImage?) {
        
        let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView = { viewModel in
            
                .init(
                    viewModel: viewModel,
                    map: { info in
                        
                            .init(
                                id: info.infoID,
                                value: info.value,
                                title: info.title,
                                image: imageCache.imagePublisher(for: info.icon),
                                style: .expanded
                            )
                    },
                    config: .iFora
                )
        }
        
        let makeUserAccountView = UserAccountView.init(viewModel:)
        let makeUtilityPrepaymentView = UtilityPrepaymentFlowWrapperView.init
        
        self.init(
            makePaymentsTransfersView: { viewModel in
                
                    .init(
                        viewModel: viewModel,
                        viewFactory: .init(
                            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                            makeUserAccountView: makeUserAccountView,
                            makeUtilityPrepaymentView: makeUtilityPrepaymentView
                        ),
                        getUImage: getUImage
                    )
            },
            makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
            makeUserAccountView: makeUserAccountView,
            makeUtilityPrepaymentView: makeUtilityPrepaymentView
        )
    }
}

private extension GetSberQRDataResponse.Parameter.Info {
    
    var infoID: InfoComponent.Info.ID {
        
        switch id {
        case .amount:        return .amount
        case .brandName:     return .brandName
        case .recipientBank: return .recipientBank
        }
    }
}

extension ImageCache {
    
    func imagePublisher(
        for icon: GetSberQRDataResponse.Parameter.Info.Icon
    ) -> ImageSubject {
        
        switch icon.type {
        case .local:
            return .init(.init(icon.value))
            
        case .remote:
            return image(forKey: .init(icon.value))
        }
    }
}
