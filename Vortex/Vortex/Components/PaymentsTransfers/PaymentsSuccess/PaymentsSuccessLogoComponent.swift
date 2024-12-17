//
//  PaymentsSuccessLogoComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 23.06.2023.
//

import SwiftUI

extension PaymentsSuccessLogoView {
    
    final class ViewModel: PaymentsParameterViewModel {
        
        let icon: Image
        let iconSize: CGSize
        let title: String?
        
        init(icon: Image, iconSize: CGSize, title: String?, source: PaymentsParameterRepresentable) {
            
            self.icon = icon
            self.iconSize = iconSize
            self.title = title
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterSuccessLogo) throws {
            
            guard let image = source.icon.image else {
                throw Error.unableCreateImageFromImageData
            }
            self.init(icon: image, iconSize: source.icon.iconSize, title: source.value, source: source)
        }
    }
}

struct PaymentsSuccessLogoView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            viewModel.icon
                .renderingMode(.original)
                .resizable()
                .frame(width: viewModel.iconSize.width, height: viewModel.iconSize.height)
                .accessibilityIdentifier("SuccessPageLogo")
            
            if let title = viewModel.title {
                
                Text(title)
                    .font(.textH3Sb18240())
                    .foregroundColor(.mainColorsBlack)
            }
        }
    }
}

extension PaymentsSuccessLogoView {
    
    enum Error: LocalizedError {
        
        case unableCreateImageFromImageData
    }
}

extension Payments.ParameterSuccessLogo.Icon {
    
    var image: Image? {
        
        switch self {
        case let .image(imageData):
            return imageData.image
            
        case let .name(imageName):
            return Image(imageName)
            
        case .sfp:
            return .ic56Sbp
        }
    }
    
    var iconSize: CGSize {
        
        switch self {
        case .sfp:
            return .init(width: 56, height: 32)
            
        default:
            return .init(width: 44, height: 44)
        }
    }
}
