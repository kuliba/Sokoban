//
//  MyProductsView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//  Full refactored by Dmitry Martynov on 18.09.2022
//

import Foundation
import InfoComponent
import SberQR
import SwiftUI

//MARK: - View

struct MyProductsView: View {
    
    @ObservedObject var viewModel: MyProductsViewModel
    
    let viewFactory: PaymentsTransfersViewFactory
    let getUImage: (Md5hash) -> UIImage?
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            MyProductsMoneyView(viewModel: viewModel.totalMoneyVM)
                .zIndex(1)
                .onTapGesture {
                    viewModel.action.send(MyProductsViewModelAction.Tapped.CancelExpandedCurrency())
                }
                .overlay13 {
                
                    if let playerViewModel = MyProductsViewModel.Onboarding.ordered.playerVM,
                       let isShow = viewModel.showOnboarding[.ordered], isShow {
                        
                        OnboardingPlayerView(viewModel: playerViewModel)
                            .frame(width: 108, height: 108)
                            .clipShape(Circle())
                            .shadow(color: Color(hex: "1C1C1C").opacity(0.1), radius: 10, x: 0, y: 12)
                            .offset(x: UIScreen.main.bounds.width / 2 - 62, y: 12)
                    }
                
                    if let playerViewModel = MyProductsViewModel.Onboarding.hide.playerVM,
                        let isShow = viewModel.showOnboarding[.hide], isShow {
                        
                        OnboardingPlayerView(viewModel: playerViewModel)
                            .frame(width: 108, height: 108)
                            .clipShape(Circle())
                            .shadow(color: Color(hex: "1C1C1C").opacity(0.1), radius: 10, x: 0, y: 12)
                            .offset(x: UIScreen.main.bounds.width / 2 - 108, y: 146)
                    }
                    
                }
            
            ZStack(alignment: .top) {
            
                ScrollView {
                    VStack {
                        ForEach(viewModel.sections) { sectionVM in
                    
                            MyProductsSectionView(viewModel: sectionVM, editMode: $viewModel.editModeState)
                                .padding(.top, 16)
                        }
                
                        Button(action: {
                            viewModel.action.send(MyProductsViewModelAction.Tapped.CancelExpandedCurrency())
                            viewModel.action.send(MyProductsViewModelAction.Tapped.NewProductLauncher())
                        }) {
                    
                            Text(viewModel.openProductTitle)
                                .font(.buttonLargeSb16180())
                                .foregroundColor(viewModel.editModeState == .active
                                                 ? .mainColorsGray : .mainColorsBlack)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(Color.barsBars)
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.editModeState == .active)
                        .padding(.horizontal)
                        .padding(.vertical, 24)
                        
                    } //vsta
                    .background(GeometryReader { geo in

                        Color.clear
                            .preference(key: ScrollOffsetKey.self,
                                        value: -geo.frame(in: .named("scroll")).origin.y)

                    })
                    .onPreferenceChange(ScrollOffsetKey.self) { offset in

                        if offset < -100 {
                            viewModel.action.send(MyProductsViewModelAction.PullToRefresh())
                        }
                    }
                }//scroll
                .background(Color.mainColorsWhite)
                .coordinateSpace(name: "scroll")
                .zIndex(0)
               
                RefreshingIndicatorView(viewModel: viewModel.refreshingIndicator).zIndex(1)
            } //zstack
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case let .openCard(authProductsViewModel):
                        AuthProductsView(viewModel: authProductsViewModel)
                        
                    case let  .openDeposit(openDepositViewModel):
                        OpenDepositListView(viewModel: openDepositViewModel, getUImage: getUImage)
                    
                    case let .productProfile(productProfileViewModel):
                        ProductProfileView(
                            viewModel: productProfileViewModel,
                            viewFactory: viewFactory,
                            getUImage: getUImage
                        )
                    }
                }
            }
            
        } //vstack
        .ignoresSafeArea(.container , edges: .bottom)
        .onAppear {
            viewModel.action.send(MyProductsViewModelAction.StartIndicator())
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                viewModel.startOnboarding()
            }
        }
        .navigationBar(with: viewModel.navigationBar)
        .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in

            switch bottomSheet.type {
                
            case let .openAccount(openAccountViewModel):
                OpenAccountView(viewModel: openAccountViewModel)
                
            case let .newProductLauncher(openProductVM):
                MyProductsOpenProductView(viewModel: openProductVM)
            }
        }
    }
}

extension MyProductsView {
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

//MARK: - Preview

struct MyProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            NavigationView {
                myProductsView(viewModel: .sample)
            }
            
            NavigationView {
                myProductsView(viewModel: .sampleOpenProduct)
            }
        }
    }
    
    static func myProductsView(
        viewModel: MyProductsViewModel
    ) -> some View {
        
        MyProductsView(
            viewModel: viewModel,
            viewFactory: .preview,
            getUImage: { _ in nil }
        )
    }
}

extension PaymentsTransfersViewFactory {
    
    static var preview: Self {
        
        return .init(
            makeSberQRConfirmPaymentView: {
                
                .init(
                    viewModel: $0,
                    map: PublishingInfo.preview(info:),
                    config: .iFora
                )
            },
            makeUserAccountView: UserAccountView.init(viewModel:),
            makeIconView: IconDomain.preview
        )
    }
}
