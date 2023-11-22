//
//  ProductProfileView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import SwiftUI
import PinCodeUI

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
                        
                    case let .paymentsTransfers(paymentsTransfersViewModel):
                        PaymentsTransfersView(viewModel: paymentsTransfersViewModel)
                        
                    }
                }
            }
            
            // workaround to fix mini-cards jumps when product name editing alert presents
            Color.clear
                .textfieldAlert(alert: $viewModel.textFieldAlert)
            
            if let closeAccountSpinner = viewModel.closeAccountSpinner {
                CloseAccountSpinnerView(viewModel: closeAccountSpinner)
            }
            
            viewModel.spinner.map { spinner in
                
                VStack {
                    SpinnerView(viewModel: spinner)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .zIndex(.greatestFiniteMagnitude)
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
        .fullScreenCover(
            item: $viewModel.fullScreenCoverState,
            content: fullScreenCoverContent
        )
        .sheet(item: $viewModel.sheet, content: { sheet in
            switch sheet.type {
            case let .printForm(printFormViewModel):
                PrintFormView(viewModel: printFormViewModel)
                
            case let .placesMap(placesViewModel):
                PlacesView(viewModel: placesViewModel)
            }
        })
        .bottomSheet(
            item: $viewModel.bottomSheet,
            content: bottomSheetContent
        )
        .alert(item: $viewModel.alert, content: { alertViewModel in
            Alert(with: alertViewModel)
        })
    }
    
    @ViewBuilder
    private func fullScreenCoverContent(
        state: ProductProfileViewModel.FullScreenCoverState
    ) -> some View {
        
        switch state {
        case let .changePin(changePIN):
            changePinCodeView(
                cardId: changePIN.cardId,
                actionType: .changePin(changePIN.displayNumber),
                changePIN.model,
                confirm: viewModel.confirmShowCVV,
                confirmChangePin: viewModel.confirmChangePin,
                showSpinner: {},
                resendRequest: changePIN.request,
                resendRequestAfterClose: viewModel.closeLinkAndResendRequest
            ).transition(.move(edge: .leading))
            
        case let .confirmOTP(confirm):
            confirmCodeView(
                phoneNumber: confirm.phone,
                cardId: confirm.cardId,
                actionType: confirm.action,
                reset: { viewModel.fullScreenCoverState = nil },
                showSpinner: {},
                resendRequest: confirm.request,
                resendRequestAfterClose: viewModel.closeLinkAndResendRequest
            ).transition(.move(edge: .leading))
            
        case let .successChangePin(viewModel):
            PaymentsSuccessView(viewModel: viewModel)
                .transaction { transaction in
                    transaction.disablesAnimations = false
                }
            
        case let .successZeroAccount(zeroAccount):
            PaymentsSuccessView(viewModel: zeroAccount.viewModel)
                .transaction { transaction in
                    transaction.disablesAnimations = false
                }
        }
    }
    
    @ViewBuilder
    private func bottomSheetContent(
        sheet: ProductProfileViewModel.BottomSheet
    ) -> some View {
        
        switch sheet.type {
        case let .operationDetail(viewModel):
            OperationDetailView(viewModel: viewModel)
            
        case let .optionsPannel(viewModel):
            ProductProfileOptionsPannelView(viewModel: viewModel)
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 72)
            
        case let .meToMeLegacy(viewModel):
            MeToMeView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.bottom)
                .frame(height: 474)
            
        case let .meToMe(viewModel):
            PaymentsMeToMeView(viewModel: viewModel)
                .fullScreenCover(item: $viewModel.success) {
                    
                    PaymentsSuccessView(viewModel: $0)
                    
                }.transaction { transaction in
                    transaction.disablesAnimations = false
                }
            
        case let .printForm(viewModel):
            PrintFormView(viewModel: viewModel)
            
        case let .placesMap(viewModel):
            PlacesView(viewModel: viewModel)
            
        case let .info(viewModel):
            OperationDetailInfoView(
                viewModel: viewModel
            )
        }
    }
    
    private func changePinCodeView(
        cardId: CardDomain.CardId,
        actionType: ConfirmViewModel.CVVPinAction,
        _ viewModel: PinCodeViewModel,
        confirm: @escaping (OtpDomain.Otp, @escaping (ErrorDomain?) -> Void) -> Void,
        confirmChangePin:  @escaping  (ConfirmViewModel.ChangePinStruct, @escaping (ErrorDomain?) -> Void) -> Void,
        showSpinner: @escaping () -> Void,
        resendRequest: @escaping () -> Void,
        resendRequestAfterClose: @escaping (CardDomain.CardId, ConfirmViewModel.CVVPinAction) -> Void
    ) -> some View {
        
        let buttonConfig: ButtonConfig = .init(
            font: .textH1R24322(),
            textColor: .textSecondary,
            buttonColor: .mainColorsGrayLightest
        )
        
        let pinConfig: PinCodeView.PinCodeConfig = .init(
            font: .textH4M16240(),
            foregroundColor: .textSecondary,
            colorsForPin: .init(
                normal: .mainColorsGrayMedium,
                incorrect: .systemColorError,
                correct: .systemColorActive,
                printing: .mainColorsBlack)
        )
        
        return PinCodeChangeView(
            config: .init(
                buttonConfig: buttonConfig,
                pinCodeConfig: pinConfig
            ),
            viewModel: viewModel,
            confirmationView: { phone, code in
                
                ConfirmCodeView(
                    phoneNumber: .init(phone.value),
                    newPin: code,
                    cardId: cardId,
                    actionType: actionType,
                    reset: viewModel.resetState,
                    resendRequest: resendRequest,
                    handler: confirm,
                    handlerChangePin: confirmChangePin,
                    showSpinner: showSpinner,
                    resendRequestAfterClose: resendRequestAfterClose
                )
            }
        )
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("")
    }
    
    private func confirmCodeView(
        phoneNumber: PhoneDomain.Phone,
        cardId: CardDomain.CardId,
        actionType: ConfirmViewModel.CVVPinAction,
        reset: @escaping () -> Void,
        showSpinner: @escaping () -> Void,
        resendRequest: @escaping () -> Void,
        resendRequestAfterClose: @escaping (CardDomain.CardId, ConfirmViewModel.CVVPinAction) -> Void
    ) -> some View {
        
        ConfirmCodeView(
            phoneNumber: phoneNumber,
            cardId: cardId,
            actionType: actionType,
            reset: reset,
            resendRequest: resendRequest,
            hasDefaultBackButton: false,
            handler: viewModel.confirmShowCVV,
            handlerChangePin: nil,
            showSpinner: showSpinner,
            resendRequestAfterClose: resendRequestAfterClose
        )
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
            ProductProfileView(viewModel: .sadSample)
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
        cvvPINServicesClient: HappyCVVPINServicesClient(),
        rootView: ""
    )
    
    static let sadSample = ProductProfileViewModel(
        navigationBar: NavigationBarView.ViewModel.sampleNoActionButton,
        product: .sample,
        buttons: .sample,
        detail: .sample,
        history: .sampleHistory,
        cvvPINServicesClient: SadCVVPINServicesClient(),
        rootView: ""
    )
}

extension NavigationBarView.ViewModel {
    
    static let sampleNoActionButton = NavigationBarView.ViewModel(
        title: "Platinum", subtitle: "· 4329",
        leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})],
        rightItems: [],
        background: .purple, foreground: .iconWhite
    )
}
