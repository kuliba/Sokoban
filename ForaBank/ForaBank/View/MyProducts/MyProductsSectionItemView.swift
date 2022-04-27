//
//  MyProductsSectionItemView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 17.04.2022.
//

import SwiftUI

struct MyProductsSectionItemView: View {
    
    @ObservedObject var viewModel: MyProductsSectionItemViewModel
    
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
                
                HStack {
                    
                    VStack {
                        
                        viewModel.icon
                            .renderingMode(.original)
                        Spacer()
                        
                    }.padding()
                    
                    VStack {
                        
                        HStack {

                            if let paymentSystemIcon = viewModel.paymentSystemIcon {

                                paymentSystemIcon
                                    .renderingMode(.original)

                            } else {

                                Divider()
                            }
                            
                            Text(viewModel.title)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                            
                            Text(viewModel.balance)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                                .frame(alignment: .trailing)
                        }
                        .padding(.top, 4)
                        
                        HStack {

                            Text(viewModel.numberCard)
                                .font(.textBodySR12160())
                                .foregroundColor(.textPlaceholder)

                            Text(viewModel.subtitle)
                                .font(.textBodySR12160())
                                .foregroundColor(.textPlaceholder)

                            Text(viewModel.dateLong)
                                .font(.textBodySR12160())
                                .foregroundColor(.textPlaceholder)
                            
                            Spacer()
                        }
                        
                        Divider()
                    }
                    .padding(.trailing)
                }
            }
            .background(Color.white)
            .offset(x: contentOffset)
            .onTapGesture {
                
                viewModel.action.send(MyProductsSectionItemAction.Tap())
            }
        }
        .frame(height: 56)
        .modifier(SwipeSidesModifier(leftAction: {

            viewModel.action.send(MyProductsSectionItemAction.SwipeDirection.Left())

        }, rightAction: {

            viewModel.action.send(MyProductsSectionItemAction.SwipeDirection.Right())
        }))
    }
}

extension MyProductsSectionItemView {
    
    struct ActionButtonView: View {
        
        var viewModel: MyProductsSectionItemViewModel.ActionButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                ZStack {
                    
                    viewModel.type.color
                    
                    VStack {
                        
                        if let icon = viewModel.type.icon {
                            Image(icon)
                        }
                        
                        Text(viewModel.type.title)
                            .foregroundColor(.white)
                            .font(.textBodySM12160())
                    }
                }
                .frame(width: 120, height: 56)
            }
        }
    }
}

struct MyProductsSectionItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            MyProductsSectionItemView(viewModel: .sample4)
                .previewLayout(.sizeThatFits)
            
            MyProductsSectionItemView(viewModel: .sample2)
                .previewLayout(.sizeThatFits)
            
            MyProductsSectionItemView(viewModel: .sample3)
                .previewLayout(.sizeThatFits)
        }
    }
}
