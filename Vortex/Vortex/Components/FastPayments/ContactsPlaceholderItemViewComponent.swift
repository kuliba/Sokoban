//
//  ContactsPlaceholderItemViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 11.11.2022.
//

import SwiftUI
import UIPrimitives

//MARK: - ViewModel

extension ContactsPlaceholderItemView {
    
    class ViewModel: ContactsItemViewModel {

        let id = UUID()
        let style: Style
        
        enum Style {
            
            case person
            case bank
            case bankPreffered
            case country
        }
        
        init(style: Style) {
            
            self.style = style
        }
    }
}

//MARK: - View

struct ContactsPlaceholderItemView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        switch viewModel.style {
        case .person:
            
            HStack(spacing: 20) {
                Circle()
                    .fill(Color.mainColorsGray.opacity(0.4))
                    .frame(width: 40, height: 40)
                
                VStack(spacing: 8) {
                    
                    Capsule()
                        .frame(height: 14)
                        .padding(.trailing, 60)
                    
                    Capsule()
                        .frame(height: 8)
                }
                .foregroundColor(.mainColorsGray.opacity(0.4))
                .padding(.trailing, 60)
                
            }.shimmering()
            
        case .bank:
            
            HStack(spacing: 20) {
                Circle()
                    .fill(Color.mainColorsGray.opacity(0.4))
                    .frame(width: 40, height: 40)
                
                VStack(spacing: 8) {
                    
                    Capsule()
                        .frame(height: 14)

                    Capsule()
                        .frame(height: 8)
                        .padding(.trailing, 60)
                }
                .foregroundColor(.mainColorsGray.opacity(0.4))
                .padding(.trailing, 120)
                
            }.shimmering()
            
        case .bankPreffered:
            
            VStack(alignment: .center, spacing: 8) {
                
                Circle()
                    .fill(Color.mainColorsGray.opacity(0.4))
                    .frame(width: 56, height: 56)
                
                VStack(alignment: .center, spacing: 8) {
                    
                    Capsule()
                        .frame(width: 65, height: 8)
                    
                    Capsule()
                        .frame(width: 45, height: 8)
                }
                .foregroundColor(.mainColorsGray.opacity(0.4))
                
            }.shimmering()

        case .country:
            
            HStack(spacing: 20) {
                Circle()
                    .fill(Color.mainColorsGray.opacity(0.4))
                    .frame(width: 40, height: 40)
                
                Capsule()
                    .frame(height: 14)
                    .foregroundColor(.mainColorsGray.opacity(0.4))
                    .padding(.trailing, 120)
                
            }.shimmering()
        }
    }
}

//MARK: - Preview

struct ContactsPlaceholderItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ContactsPlaceholderItemView(viewModel: .init(style: .person))
                .previewLayout(.fixed(width: 375, height: 100))
            
            ContactsPlaceholderItemView(viewModel: .init(style: .bank))
                .previewLayout(.fixed(width: 375, height: 100))
            
            ContactsPlaceholderItemView(viewModel: .init(style: .bankPreffered))
                .previewLayout(.fixed(width: 375, height: 100))
            
            ContactsPlaceholderItemView(viewModel: .init(style: .country))
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}
