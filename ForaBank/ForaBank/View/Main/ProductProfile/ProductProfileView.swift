//
//  ProductProfileView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import SwiftUI

struct ProductProfileView: View {
    
    @ObservedObject var viewModel: ProductProfileViewModel

    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView {
                
                ZStack {
                    
                    Group {
                        
                        GeometryReader { geometry in
                            
                            ZStack {
                                
                                if geometry.frame(in: .global).minY <= 0 {
                                    
                                    viewModel.accentColor.contrast(0.5)
                                        .frame(width: geometry.size.width, height: 204)
                                        .offset(y: geometry.frame(in: .global).minY / 9)
                                        .clipped()
                                    
                                } else {
                                    
                                    viewModel.accentColor.contrast(0.5)
                                        .frame(width: geometry.size.width, height: 204 + geometry.frame(in: .global).minY)
                                        .clipped()
                                        .offset(y: -geometry.frame(in: .global).minY)
                                }
                            }
                        }
                    }
                    .zIndex(0)
                    
                    VStack(spacing: 0) {
                        
                        ProductProfileCardView(viewModel: viewModel.product)
                        
                        VStack(spacing: 32) {
                            
                            ProductProfileButtonsView(viewModel: viewModel.buttons)
                                .padding(.horizontal, 20)
                            
                            if let detailAccount = viewModel.detail {
                                
                                ProductProfileDetailView(viewModel: detailAccount)
                                    .padding(.horizontal, 20)
                            }
                            
                            if let historyViewModel = viewModel.history {
                                
                                ProductProfileHistoryView(viewModel: historyViewModel)
                            }
                        }
                    }
                    .padding(.top, 56)
                    .zIndex(1)
                }
                .background(GeometryReader { geo in
                    
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: -geo.frame(in: .named("scroll")).origin.y)
           
                })
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    
                    if offset < -100 {
                        
                        viewModel.action.send(ProductProfileViewModelAction.PullToRefresh())
                    }
                }
                
            }.coordinateSpace(name: "scroll")
            
            StatusView(viewModel: viewModel.statusBar)
                .frame(height: 48)
                .background(viewModel.accentColor.contrast(0.5).edgesIgnoringSafeArea(.top))
        }
        .navigationBarHidden(true)
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
        .bottomSheet(item: $viewModel.sheet, content: { sheet in
            
            switch sheet.type {
            case let .operationDetail(operationDetailViewModel):
                OperationDetailView(viewModel: operationDetailViewModel)
            }
        })
    }
}

//MARK: - Internal Views

extension ProductProfileView {
    
    struct StatusView: View {
        
        @ObservedObject var viewModel: ProductProfileViewModel.StatusBarViewModel
        
        var body: some View {
            
            HStack {
                
                Button(action: viewModel.backButton.action) {
                    
                    viewModel.backButton.icon
                        .foregroundColor(viewModel.textColor)
                }

                Spacer()
                
                VStack {
                    
                    Text(viewModel.title)
                        .font(.textH3M18240())
                        .foregroundColor(viewModel.textColor)
                    
                    Text(viewModel.subtitle)
                        .font(.textBodySR12160())
                        .foregroundColor(viewModel.textColor)
                }
                
                Spacer()
                
                if let actionButtonViewModel = viewModel.actionButton {
                    
                    Button(action: actionButtonViewModel.action) {
                        
                        actionButtonViewModel.icon
                            .foregroundColor(viewModel.textColor)
                    }
                    
                } else {
                    
                    Color.clear
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 20)
            .background(Color.clear)
        }
    }
}

extension ProductProfileView {
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

//MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductProfileView(viewModel: .sample)
 
            ProductProfileView.StatusView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 48))
            ProductProfileView.StatusView(viewModel: .sampleNoActionButton)
                .previewLayout(.fixed(width: 375, height: 48))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileViewModel {
    
    static let sample = ProductProfileViewModel(statusBar: .sample, product: .sample, buttons: .sample, detail: nil, history: .sampleHistory)
}

extension ProductProfileViewModel.StatusBarViewModel {
    
    static let sample = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: {}), title: "Platinum", subtitle: "· 4329", actionButton: .init(icon: .ic24Edit2, action: {}), textColor: .iconBlack)
    
    static let sampleNoActionButton = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: {}), title: "Platinum", subtitle: "· 4329", actionButton: nil, textColor: .iconBlack)
}


