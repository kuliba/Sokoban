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
    
    init(with model: Model) {
        
        let imageCache = model.imageCache()
        
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

private extension ImageCache {
    
    func imagePublisher(
        for icon: GetSberQRDataResponse.Parameter.Info.Icon
    ) -> AnyPublisher<Image, Never> {
        
        switch icon.type {
        case .local:
            return Just(.init(icon.value)).eraseToAnyPublisher()
            
        case .remote:
            return image(forKey: icon.imageKey)
        }
    }
}

private extension GetSberQRDataResponse.Parameter.Info.Icon {
    
    var imageKey: ImageCache.ImageKey { .init(value) }
}

private extension Model {
    
    func imageCache() -> ImageCache {
        
        .init(
            requestImages: {
                
                self.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: $0.map(\.rawValue)))
            },
            imagesPublisher: images
        )
    }
}
