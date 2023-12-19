//
//  RootViewFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

import Combine
import SberQR
import SwiftUI

extension RootViewFactory {
    
    init(with imageCache: ImageCache) {
        
        self.init(
            makeSberQRConfirmPaymentView: { viewModel in
                
                .init(
                    viewModel: viewModel,
                    map: { info in
                        
                        .init(
                            id: info.id,
                            value: info.value,
                            title: info.title,
                            image: imageCache.imagePublisher(for: info.icon)
                        )
                    },
                    config: .iFora
                )
            }
        )
    }
}

extension ImageCache {
    
    func imagePublisher(
        for icon: GetSberQRDataResponse.Parameter.Info.Icon
    ) -> AnyPublisher<Image, Never> {
        
        switch icon.type {
        case .local:
            return Just(.init(icon.value)).eraseToAnyPublisher()
            
        case .remote:
            return image(forKey: .init(icon.value))
        }
    }
}
