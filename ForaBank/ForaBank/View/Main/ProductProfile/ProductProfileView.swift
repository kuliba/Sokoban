//
//  ProductProfileView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import SwiftUI

struct ProductProfileView: View {
    
    @ObservedObject var viewModel: ProductProfileViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var accentColor: some View {
        
        return viewModel.accentColor.overlay(Color(hex: "1с1с1с").opacity(0.3))
    }

    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView {
                
                ZStack {
                    
                    Group {
                        
                        GeometryReader { geometry in
                            
                            ZStack {
                                
                                if geometry.frame(in: .global).minY <= 0 {
                                    
                                    accentColor
                                        .frame(width: geometry.size.width, height: 204 - 48)
                                        .offset(y: geometry.frame(in: .global).minY / 9)
                                        .clipped()
                                    
                                } else {
                                    
                                    accentColor
                                        .frame(width: geometry.size.width, height: 204 - 48 + geometry.frame(in: .global).minY)
                                        .clipped()
                                        .offset(y: -geometry.frame(in: .global).minY)
                                }
                            }
                        }
                    }
                    .zIndex(0)
                    
                    VStack(spacing: 12) {
                        
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
                    .padding(.top, 56 - 48)
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
                            .edgesIgnoringSafeArea(.bottom)
                        
                    case let .productStatement(productStatementViewModel):
                        ProductStatementView(viewModel: productStatementViewModel)
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarTitle("Выписка по счету")
                        
                    case let .meToMeExternal(meToMeExternalViewModel):
                        
                        MeToMeExternalView(viewModel: meToMeExternalViewModel)
                            .edgesIgnoringSafeArea(.bottom)
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarTitle("Пополнить со счета в другом банке")
                            .navigationBarItems(trailing: Image(uiImage: UIImage(named: "logo-spb-mini") ?? UIImage()))
                        
                    case let .myProducts(myProductsViewModel):
                        MyProductsView(viewModel: myProductsViewModel)
                        
                    }
                }
            }
            
            // workaround to fix mini-cards jumps when product name editing alert presents
            Color.clear
                .textfieldAlert(alert: $viewModel.textFieldAlert)

            if let closeAccountSpinner = viewModel.closeAccountSpinner {
                CloseAccountSpinnerView(viewModel: closeAccountSpinner)
            }
            
            if let spinner = viewModel.spinner {
                
                VStack {
                    
                    SpinnerView(viewModel: spinner)
                }
                .frame(width: .infinity, height: .infinity, alignment: .center)
            }
            
            Color.clear.frame(maxHeight: 0)
                .fullScreenCover(item: $viewModel.successZeroAccount) { successViewModel in
                    PaymentsSuccessView(viewModel: successViewModel.viewModel)

                }.transaction { transaction in
                    transaction.disablesAnimations = false
                }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBar(with: viewModel.navigationBar)
        .onReceive(viewModel.action) { action in
            switch action {
            case _ as ProductProfileViewModelAction.Close.SelfView:
                self.mode.wrappedValue.dismiss()
                
            default: break
            }
        }
        .sheet(item: $viewModel.sheet, content: { sheet in
            switch sheet.type {
            case let .printForm(printFormViewModel):
                PrintFormView(viewModel: printFormViewModel)

            case let .placesMap(placesViewModel):
                PlacesView(viewModel: placesViewModel)
            }
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
                
            case let .meToMeLegacy(meToMeViewModel):
                MeToMeView(viewModel: meToMeViewModel)
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(height: 474)
                
            case let .meToMe(viewModel):
                PaymentsMeToMeView(viewModel: viewModel)
                    .fullScreenCover(item: $viewModel.success) { successViewModel in

                        PaymentsSuccessView(viewModel: successViewModel)

                    }.transaction { transaction in
                        transaction.disablesAnimations = false
                    }
                                
            case let .printForm(printFormViewModel):
                PrintFormView(viewModel: printFormViewModel)
                
            case let .placesMap(placesViewModel):
                PlacesView(viewModel: placesViewModel)
                
            case let .info(operationDetailInfoViewModel):
                OperationDetailInfoView(viewModel: operationDetailInfoViewModel)
            }
        })
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
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
        buttons: .sample,
        detail: .sample,
        history: .sampleHistory,
        rootView: "")
}

extension NavigationBarView.ViewModel {

    static let sampleNoActionButton = NavigationBarView.ViewModel(
        title: "Platinum", subtitle: "· 4329",
        leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})],
        rightItems: [],
        background: .purple, foreground: .iconWhite)
}
