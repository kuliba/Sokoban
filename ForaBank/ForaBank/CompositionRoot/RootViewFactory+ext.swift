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
            image: image(info.icon)
        )
    }
    
    func image(
        _ icon: GetSberQRDataResponse.Parameter.Info.Icon
    ) -> Image {
        
        switch icon.type {
        case .local:
            return Image(icon.value)
            
        case .remote:
            guard 
                let imageData = images.value[icon.value],
                let image = imageData.image
            else {
                // TODO: rethink failure case
                return Image(.avatar)
            }
            
            return image
        }
    }
}
