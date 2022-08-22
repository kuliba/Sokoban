//
//  MyProductsSectionItemView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 17.04.2022.
//

import SwiftUI

struct MyProductsSectionItemView: View {
    
    @ObservedObject var viewModel: MyProductsSectionProductItemViewModel
    
    var contentOffset: CGFloat {
        
        switch viewModel.state {
        case .rightButton: return -120
        case .leftButton: return 120
        default: return 0
        }
    }
    
    var body: some View {
        
        ZStack {
            
            HStack {
                
                switch viewModel.state {
                case let .leftButton(viewModel):
                    ActionButtonView(viewModel: viewModel)
                    Spacer()
                case let .rightButton(viewModel):
                    Spacer()
                    ActionButtonView(viewModel: viewModel)
                default:
                    EmptyView()
                }
            }
            
            ZStack {
                
                HStack(spacing: 16) {
                    
                    VStack {
                        if let icon = viewModel.icon {
                            icon
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 32, height: 22)
                        } else {
                            EmptyView()
                                .frame(width: 32, height: 22)
                            //TODO: Placeholder Image
                        }
                        Spacer()
                        
                    }
                    .padding(.top, 4)
                    .padding(.leading, 20)

                    VStack(spacing: 8) {
                        
                        HStack {

                            if let paymentSystemIcon = viewModel.paymentSystemIcon {
                                paymentSystemIcon
                                    .renderingMode(.original)
                            }
                            
                            Text(viewModel.title)
                                .font(.textBodyMM14200())
                                .foregroundColor(.mainColorsBlack)
                            
                            Spacer()
                            
                            Text(viewModel.currencyBalance)
                                .font(.textBodyMM14200())
                                .foregroundColor(.mainColorsBlack)
                                .frame(alignment: .trailing)
                        }
                        .padding(.top, 4)
                        
                        HStack {

                            Text(viewModel.numberCard)
                                .font(.textBodySR12160())
                                .foregroundColor(.mainColorsGray)
                            
                            if let subtitle = viewModel.subtitle {
                                Text(subtitle)
                                    .font(.textBodySR12160())
                                    .foregroundColor(.mainColorsGray)
                            }
                            
                            if let dateLong = viewModel.dateLong {
                                Text(dateLong)
                                    .font(.textBodySR12160())
                                    .foregroundColor(.mainColorsGray)
                            }
                            Spacer()
                        }
                        
                        Divider()
                            .background(Color.mainColorsGrayLightest)
                            .opacity(0.5)
                    }
                    .padding(.trailing, 20)
                }
            }
            .background(Color.mainColorsWhite)
            .offset(x: contentOffset)
            .onTapGesture {
                
                viewModel.action.send(MyProductsSectionItemAction.Tap(productId: viewModel.id))
            }
        }
        .frame(height: 60)
        .modifier(SwipeSidesModifier(leftAction: {

            viewModel.action.send(MyProductsSectionItemAction.SwipeDirection.Left())

        }, rightAction: {

            switch viewModel.state {
            case .normal:
                guard viewModel.isNeedsActivated else {
                    return
                }
            default:
                break
            }

            viewModel.action.send(MyProductsSectionItemAction.SwipeDirection.Right())
        }))
    }
}

extension MyProductsSectionItemView {
    
    struct ActionButtonView: View {
        
        var viewModel: MyProductsSectionProductItemViewModel.ActionButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                ZStack {
                    
                    viewModel.type.color
                    
                    VStack {
                        
                        if let icon = viewModel.type.icon {
                            Image(icon)
                        }
                        
                        Text(viewModel.type.title)
                            .foregroundColor(.mainColorsWhite)
                            .font(.textBodySM12160())
                    }
                }
                .frame(width: 120, height: 60)
            }
        }
    }
}

struct MyProductsSectionButtonItemView: View {
    
    @ObservedObject var viewModel: MyProductsSectionButtonItemViewModel
    
    var body: some View {
        
        ZStack {
            
            HStack(spacing: 16) {
                
                VStack {
                    
                    viewModel.icon
                        .renderingMode(.original)
                    
                    Spacer()
                    
                }
                .padding(.top, 4)
                .padding(.leading, 20)
                
                VStack(spacing: 8) {
                    
                    HStack {
                        
                        Text(viewModel.title)
                            .font(.textBodyMM14200())
                            .foregroundColor(.mainColorsBlack)
                        
                        Spacer()
                        
                    }
                    .padding(.top, 4)
                    
                    HStack {
                        
                        if let subtitle = viewModel.subtitle {
                            Text(subtitle)
                                .font(.textBodySR12160())
                                .foregroundColor(.mainColorsGray)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                        .background(Color.mainColorsGrayLightest)
                        .opacity(0.5)
                }
                .padding(.trailing, 20)
                
            }
            .background(Color.mainColorsWhite)
            .onTapGesture {
                
                viewModel.action.send(MyProductsSectionItemAction.PlaceholderTap(type: viewModel.type))
            }
        }
        .frame(height: 60)
        
    }
}

struct MyProductsSectionItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            MyProductsSectionItemView(viewModel: .sample7)
                .previewLayout(.sizeThatFits)
            
            MyProductsSectionItemView(viewModel: .sample8)
                .previewLayout(.sizeThatFits)
            
            MyProductsSectionItemView(viewModel: .sample9)
                .previewLayout(.sizeThatFits)
            
            MyProductsSectionButtonItemView(viewModel: .sample10)
                .previewLayout(.sizeThatFits)
        }
    }
}
