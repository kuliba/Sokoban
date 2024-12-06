//
//  PaymentsSuccessOptionsComponent.swift
//  Vortex
//
//  Created by Max Gribov on 23.06.2023.
//

import SwiftUI

extension PaymentsSuccessOptionsView {
    
    final class ViewModel: PaymentsParameterViewModel {
        
        let options: [OptionViewModel]
        
        init(options: [OptionViewModel], source: PaymentsParameterRepresentable) {
            
            self.options = options
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterSuccessOptions) {
            
            self.init(
                options: source.options
                    .map(OptionViewModel.init(with:))
                    .compactMap{ $0 },
                source: source)
        }
    }
    
    struct OptionViewModel: Identifiable {

        let id: UUID
        let image: Image
        let title: String
        let subTitle: String?
        let description: String
        
        init(id: UUID = UUID(), image: Image, title: String, subTitle: String? = nil, description: String) {
            
            self.id = id
            self.image = image
            self.title = title
            self.subTitle = subTitle
            self.description = description
        }
        
        init?(with option: Payments.ParameterSuccessOptions.Option) {
            
            guard let image = option.icon.image else {
                return nil
            }
            
            self.init(image: image, title: option.title, subTitle: option.subTitle, description: option.description)
        }
    }
}

struct PaymentsSuccessOptionsView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        HStack {
            
            VStack(alignment: .leading,spacing: 24) {
                
                ForEach(viewModel.options) { optionViewModel in
                    
                    OptionView(viewModel: optionViewModel)
                }
            }
            
            Spacer()
            
        }.padding(.horizontal, 20)
    }
    
    struct OptionView: View {
        
        let viewModel: PaymentsSuccessOptionsView.OptionViewModel
        
        var body: some View {
            
            HStack(spacing: 14) {
                
                viewModel.image
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsGray)
                    
                    Text(viewModel.description)
                        .font(.textH4M16240())
                        .foregroundColor(.mainColorsBlack)
                    
                    if let subTitle = viewModel.subTitle {
                        
                        Text(subTitle)
                            .font(.textBodyMR14200())
                            .foregroundColor(.mainColorsGray)
                    }
                }
            }
        }
    }
}

extension Payments.ParameterSuccessOptions.Icon {
    
    var image: Image? {
        
        switch self {
        case let .image(imageData):
            return imageData.image
            
        case let .name(imageName):
            return Image(imageName)
        }
    }
}

