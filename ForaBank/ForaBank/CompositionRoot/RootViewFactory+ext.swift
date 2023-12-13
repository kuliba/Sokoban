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
        
        self.init(
            makeSberQRConfirmPaymentView: {
                
                .init(
                    viewModel: $0,
                    map: model.map,
                    config: .iFora
                )
            }
        )
    }
}

private extension Model {
    
    func map(
        _ info: GetSberQRDataResponse.Parameter.Info
    ) -> Info {
        
        .init(
            id: info.id,
            value: info.value,
            title: info.title,
            image: { [weak self] in self?.image(info.icon, $0) }
        )
    }
    
    func image(
        _ icon: GetSberQRDataResponse.Parameter.Info.Icon,
        _ completion: @escaping (Image) -> Void
    ) {
        switch icon.type {
        case .local:
            completion(.init(icon.value))
            
        case .remote:
            let imageCache = ImageCache(model: self)
            imageCache.image(
                for: .init(icon.value),
                completion: {
                    
                    completion($0)
//                    _ = imageCache
                }
            )
        }
    }
}
