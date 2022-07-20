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
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case .productInfo(let productInfoViewModel):
                        InfoProductView(viewModel: productInfoViewModel)
                        
                    case let .productStatement(productStatementViewModel):
                        ProductStatementView(viewModel: productStatementViewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                        
                    case let .meToMeExternal(meToMeExternalViewModel):
                        MeToMeExternalView(viewModel: meToMeExternalViewModel)
                            .navigationBarTitle("", displayMode: .inline)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }
            }
        }
        .navigationBar(with: viewModel.navigationBar)
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
        .bottomSheet(item: $viewModel.bottomSheet, content: { sheet in
            
            switch sheet.type {
            case let .operationDetail(operationDetailViewModel):
                OperationDetailView(viewModel: operationDetailViewModel)
                
            case let .optionsPannel(optionsPannelViewModel):
                ProductProfileOptionsPannelView(viewModel: optionsPannelViewModel)
                    .padding(.horizontal, 20)
                    .padding(.top, 26)
                    .padding(.bottom, 72)
                
            case let .meToMe(meToMeViewModel):
                MeToMeView(viewModel: meToMeViewModel)
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(height: 540)
            }
        })
        .sheet(item: $viewModel.sheet, content: { sheet in
            switch sheet.type {
            case let .printForm(printFormViewModel):
                PrintFormView(viewModel: printFormViewModel)
                
            case .placesMap(let placesViewModel):
                PlacesView(viewModel: placesViewModel)
                
            }
        })
        .textfieldAlert(alert: $viewModel.textFieldAlert)
    }
}

//MARK: - Internal Views

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
        }
    }
}

//MARK: - Preview Content

extension ProductProfileViewModel {
    
    static let sample = ProductProfileViewModel(
        navigationBar: NavigationBarView.ViewModel.sampleNoActionButton,
        product: .sample,
        buttons: .sample, detail: nil,
        history: .sampleHistory)
}

extension NavigationBarView.ViewModel {

    static let sampleNoActionButton = NavigationBarView.ViewModel(
        title: "Platinum", subtitle: "· 4329",
        leftButtons: [BackButtonViewModel(icon: .ic24ChevronLeft, action: {})],
        rightButtons: [],
        background: .purple, foreground: .iconWhite)
}
