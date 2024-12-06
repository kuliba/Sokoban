//
//  PaymentsServicesOperatorItemView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 24.03.2023.
//

import SwiftUI

//MARK: - View Model

extension PaymentsServicesOperatorItemView {
    
    class ViewModel: PaymentsServicesItemViewModel {
        
        let code: String
        let icon: Image?
        let name: String
        let description: String?
        let region: String?
        let action: (String) -> Void
        
        init(code: String, icon: Image?, name: String, description: String?, region: String?, action: @escaping (String) -> Void) {
            
            self.code = code
            self.icon = icon
            self.name = name
            self.description = description
            self.region = region
            self.action = action
        }
        
        convenience init(code: String, icon: ImageData?, name: String, description: String?, region: String?, action: @escaping (String) -> Void) {
            
            let iconImage = icon?.image
            self.init(code: code, icon: iconImage, name: name, description: description, region: region, action: action)
        }
    }
}

//MARK: - View

struct PaymentsServicesOperatorItemView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        Button(action: {
            viewModel.action(viewModel.code) }) {
            
            HStack(alignment: .center, spacing: 20) {
                
                if let icon = viewModel.icon {
                    
                    icon
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(90)
                    
                } else {
                    
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.name)
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(1)
                        .font(.textH4M16240())
                    
                    if let description = viewModel.description,
                       !description.isEmpty {
                        
                        Text(description)
                            .foregroundColor(Color.textPlaceholder)
                            .lineLimit(1)
                            .font(.textBodyMR14180())
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

//MARK: - Preview

struct PaymentsServicesOperatorItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsServicesOperatorItemView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 100))
    }
}

//MARK: - Preview Content

extension PaymentsServicesOperatorItemView.ViewModel {
    
    static let sample = PaymentsServicesOperatorItemView.ViewModel(code: "iFora||116", icon: .ic40TvInternet, name: "Qwerty (Центел)", description: "7878787", region: nil, action: {_ in })
}
