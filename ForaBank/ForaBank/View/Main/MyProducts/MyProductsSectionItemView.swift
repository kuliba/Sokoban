//
//  MyProductsSectionItemView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 17.04.2022.
//  Full refactored by Dmitry Martynov on 18.09.2022
//

import SwiftUI
import Shimmer

struct MyProductsSectionItemView: View {
    
    @ObservedObject var viewModel: MyProductsSectionItemViewModel
    @Binding var editMode: EditMode
    
    private var contentOffset: CGFloat {
        
        guard let sideButton = viewModel.sideButton else {
            return 0
        }
        
        switch sideButton {
        case .right: return 146
        case .left: return -146
        }
    }
    
    var body: some View {
        
        ZStack {
            
            if let sideButtonViewModel = viewModel.sideButton {

                SideButtonView(viewModel: sideButtonViewModel)
            }
            
            BaseItemView(viewModel: viewModel, editMode: $editMode)
                .offset(x: contentOffset)
        }
    }

}

extension MyProductsSectionItemView {
    
    struct BaseItemView: View {
        
        @ObservedObject var viewModel: MyProductsSectionItemViewModel
        @Binding var editMode: EditMode
        
        var body: some View {
            
            ZStack(alignment: .center) {
                
                Color.barsBars
                
                HStack(alignment: .center ,spacing: 16) {
                    
                    MyProductsSectionItemView.IconView(viewModel: viewModel.icon)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        HStack {
                            
                            viewModel.paymentSystemIcon.map {
                                $0.renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 24, height: 24, alignment: .center)
                                    .accessibilityIdentifier("MyProductsProductPaymentSistemIcon")
                            }
                            
                            Text(viewModel.name).lineLimit(1)
                                .accessibilityIdentifier("MyProductsProductName")
                            
                            Spacer()
                            
                            Text(viewModel.balance).accessibilityIdentifier("MyProductsProductBalance")
                
                        }
                        .font(.textH4M16240())
                        .foregroundColor(.mainColorsBlack)
                        .padding(.top, 12)

                        HStack(spacing: 8) {
                            
                            viewModel.clover().map {
                                
                                $0
                                    .renderingMode(.template)
                                    .foregroundColor(.mainColorsGray)
                            }
                            
                            ForEach(viewModel.descriptions, id: \.self) { description in
                                
                                Circle().frame(width: 3)
                                
                                Text(description).font(.textBodyMR14180())
                                    .accessibilityIdentifier("MyProductsProductDescription")
                            }
                            .foregroundColor(.mainColorsGray)
                            
                        }.padding(.bottom, 12)
                      
                    }.padding(.trailing, 12)
                }
            }
            .frame(height: 72)
            .padding(.leading, editMode == .active ? viewModel.orderModePadding : 12)
            .background(Color.barsBars)
            .onTapGesture {
                viewModel.action.send(MyProductsSectionItemAction.ItemTapped())
            }
        }
    }
    
    struct IconView: View {
        
        @ObservedObject var viewModel: MyProductsSectionItemViewModel.IconViewModel
        
        var body: some View {
            
            ZStack(alignment: .trailing) {
                
                switch viewModel.background {
                case let .image(baseImage):
                    baseImage.renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32)
                        .accessibilityIdentifier("MyProductsProductIcon")
                    
                case let .color(baseColor):
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundColor(baseColor)
                        .frame(width: 32, height: 22)
                }
                
                if let overlay = viewModel.overlay {
                    
                    overlay.image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(overlay.imageColor)
                        .frame(width: 32, height: 12)
                        .accessibilityIdentifier("MyProductsProductIconStateImage")
                }
            }
            .shimmering(active: viewModel.isUpdating, bounce: true)
        }
    }
    
    struct PlaceholderItemView: View {
        
        @Binding var editMode: EditMode
        var body: some View {
            
            ZStack {
                
                Color.barsBars
                
                HStack(alignment: .center ,spacing: 16) {
                
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundColor(.mainColorsGrayMedium)
                        .frame(width: 32, height: 22)
                
                    VStack(spacing: 4) {
                
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.mainColorsGrayMedium)
                            .frame(height: 12)
                            .padding(.trailing, 12)
                    
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.mainColorsGrayMedium)
                            .frame(height: 12)
                            .padding(.trailing, 130)
                    }
                }
                .shimmering(active: true, bounce: true)
            }
            .frame(height: 72)
            .padding(.leading, editMode == .active ? 0 : 12)
            .background(Color.barsBars)
        }
    }
    
    struct SideButtonView: View {
        
        let viewModel: MyProductsSectionItemViewModel.SideButtonViewModel
        
        var body: some View {
            
            HStack {
                
                switch viewModel {
                case let .left(viewModel):
                    Spacer()
                    MyProductsSectionItemView.ActionButtonView(viewModel: viewModel)
                    
                    
                case let .right(viewModel):
                    MyProductsSectionItemView.ActionButtonView(viewModel: viewModel)
                    Spacer()
                }
            }
        }
    }
    
    struct ActionButtonView: View {
        
        var viewModel: MyProductsSectionItemViewModel.ActionButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                ZStack {
                    
                    viewModel.type.color
                    
                    HStack {
                        
                        viewModel.type.icon
                            .renderingMode(.template)
                            .foregroundColor(.mainColorsWhite)
                        
                        Text(viewModel.type.title)
                            .foregroundColor(.mainColorsWhite)
                            .font(.textBodyMR14200())
                    }
                }
                .frame(width: 146, height: 72)
            }
        }
    }
}

struct MyProductsSectionItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            MyProductsSectionItemView
                .BaseItemView(viewModel: .sample7, editMode: .constant(.inactive))
                .previewDisplayName("BaseItem")
                .previewLayout(.sizeThatFits)
            
            MyProductsSectionItemView(viewModel: .sample7, editMode: .constant(.inactive))
                .previewLayout(.sizeThatFits)
            
            MyProductsSectionItemView(viewModel: .sample8, editMode: .constant(.inactive))
                .previewLayout(.sizeThatFits)
            
            MyProductsSectionItemView(viewModel: .sample9, editMode: .constant(.inactive))
                .previewLayout(.sizeThatFits)
            
        }
    }
}

