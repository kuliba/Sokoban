//
//  PaymentsSuccessIconView.swift
//  Vortex
//
//  Created by Max Gribov on 14.03.2023.
//

import SwiftUI

//MARK: - View Model

extension PaymentsSuccessIconView {
    
    final class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        var parameterSuccessIcon: Payments.ParameterSuccessIcon? { source as? Payments.ParameterSuccessIcon }
        
        var image: Image? {
            
            guard let parameterSuccessIcon = parameterSuccessIcon else {
                return nil
            }
            
            switch parameterSuccessIcon.icon {
            case let .image(imageData): return imageData.image
            case let .name(imageName): return Image(imageName)
            }
        }
        
        var size: CGFloat {
            
            guard let parameterSuccessIcon = parameterSuccessIcon else {
                return 40
            }
            
            switch parameterSuccessIcon.size {
            case .normal: return 40
            case .small: return 32
            }
        }
        
        init(_ source: Payments.ParameterSuccessIcon) {
            
            super.init(source: source)
        }
    }
}

//MARK: - View

struct PaymentsSuccessIconView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        if let image = viewModel.image {
            
            image
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(height: viewModel.size)
                .accessibilityIdentifier("SuccessPageImage")
            
        } else {
            
            Circle()
                .frame(height: viewModel.size)
                .foregroundColor(.mainColorsGrayLightest)
                .accessibilityIdentifier("SuccessPageDefaultImage")
        }
    }
}

//MARK: - Preview

struct PaymentsSuccessIconView_Previews: PreviewProvider {

    static var previews: some View {

        Group {
            
            PaymentsSuccessIconView(viewModel: .sampleName)
                .previewLayout(.fixed(width: 100, height: 100))
                .previewDisplayName("Name")
            
            PaymentsSuccessIconView(viewModel: .sampleImage)
                .previewLayout(.fixed(width: 100, height: 100))
                .previewDisplayName("Image")
            
            PaymentsSuccessIconView(viewModel: .sampleImageSmall)
                .previewLayout(.fixed(width: 100, height: 100))
                .previewDisplayName("Image Small")
        }
    }
}

//MARK: - Preview Content

extension PaymentsSuccessIconView.ViewModel {
    
    static let sampleName = PaymentsSuccessIconView.ViewModel(.init(icon: .name("ic40Sbp"), size: .normal))
    
    static let sampleImage = PaymentsSuccessIconView.ViewModel(.init(icon: .image(.init(named: "Bank Logo Sample")!), size: .normal))
    
    static let sampleImageSmall = PaymentsSuccessIconView.ViewModel(.init(icon: .image(.init(named: "Bank Logo Sample")!), size: .small))
}
