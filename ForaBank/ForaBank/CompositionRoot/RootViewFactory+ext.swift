//
//  RootViewFactory+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 13.12.2023.
//

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
                            image: { completion in
                            
                                imageCache.image(
                                    forKey: .init(info.value),
                                    completion: completion
                                )
                            }
                        )
                    },
                    config: .iFora
                )
            }
        )
    }
}

private extension Model {
    
    func imageCache() -> ImageCache {
        
        .init(
            requestImages: {
                
                self.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: $0))
            },
            imagesPublisher: images
        )
    }
}
