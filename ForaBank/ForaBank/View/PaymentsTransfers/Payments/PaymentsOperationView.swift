//
//  PaymentsOperationViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.02.2022.
//

import SwiftUI
import Combine
import IQKeyboardManagerSwift

struct PaymentsOperationView: View {
    
    @ObservedObject var viewModel: PaymentsOperationViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var topSize: CGSize = .zero
    @State private var bottomSize: CGSize = .zero
    
    var body: some View {
        
        ZStack {

            // content
            ScrollView(showsIndicators: false) {
                
                ScrollViewReader { reader in
                    
                    VStack(spacing: 24) {
                        
                        Color.clear
                            .frame(height: topSize.height)
                        
                        ForEach(viewModel.content) { item in
                            
                            switch item {
                            case let selectViewModel as PaymentsSelectView.ViewModel:
                                PaymentsSelectView(viewModel: selectViewModel)

                            case let selectBankViewModel as PaymentsSelectBankView.ViewModel:
                                PaymentsSelectBankView(viewModel: selectBankViewModel)
                                
                            case let selectViewModels as PaymentsSelectSimpleView.ViewModel:
                                PaymentsSelectSimpleView(viewModel: selectViewModels)
                                
                            case let switchViewModel as PaymentsSwitchView.ViewModel:
                                PaymentsSwitchView(viewModel: switchViewModel)
                                
                            case let inputViewModel as PaymentsInputView.ViewModel:
                                PaymentsInputView(viewModel: inputViewModel)
                                
                            case let checkBoxViewModel as PaymentsCheckBoxView.ViewModel:
                                PaymentsCheckBoxView(viewModel: checkBoxViewModel)
                                
                            case let inputPhoneViewModel as PaymentsInputPhoneView.ViewModel:
                                PaymentsInputPhoneView(viewModel: inputPhoneViewModel)
                                
                            case let infoViewModel as PaymentsInfoView.ViewModel:
                                PaymentsInfoView(viewModel: infoViewModel)
                                
                            case let nameViewModel as PaymentsNameView.ViewModel:
                                PaymentsNameView(viewModel: nameViewModel)
                                
                            case let cardViewModel as PaymentsProductView.ViewModel:
                                PaymentsProductView(viewModel: cardViewModel)
                                
                            case let codeViewModel as PaymentsCodeView.ViewModel:
                                PaymentsCodeView(viewModel: codeViewModel)
                                    .onAppear {
                                        
                                        //FIXME: get rid of this!!!
                                        IQKeyboardManager.shared.enable = true
                                        IQKeyboardManager.shared.enableAutoToolbar = true
                                        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
                                        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
                                    }
                                    .onDisappear {
                                        
                                        IQKeyboardManager.shared.enable = false
                                        IQKeyboardManager.shared.enableAutoToolbar = false
                                    }
                                
                            case let additionButtonViewModel as PaymentsSpoilerButtonView.ViewModel:
                                PaymentsSpoilerButtonView(viewModel: additionButtonViewModel)
                                
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Color.clear
                            .frame(height: bottomSize.height)
                            .id("bottom")
                        
                    }.onChange(of: viewModel.content.count) { _ in
                        
                        reader.scrollTo("bottom")
                    }
                }
            }
            
            // top
            if let topItems = viewModel.top {
                
                VStack {
                    
                    ForEach(topItems) { item in
                        
                        switch item {
                        case let switchViewModel as PaymentsSwitchView.ViewModel:
                            PaymentsSwitchView(viewModel: switchViewModel)
                                .padding(.horizontal, 20)
                            
                        case let messageViewModel as PaymentsMessageView.ViewModel:
                            PaymentsMessageView(viewModel: messageViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.vertical, 8)
                    .modifier(TopBackgroundModifier())
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: PaymentsOperationViewTopHeightPreferenceKey.self, value: proxy.size)
                        }
                    )
                    .onPreferenceChange(PaymentsOperationViewTopHeightPreferenceKey.self, perform: { value in
                        
                        withAnimation {
                            self.topSize = value
                        }
                    })
                    
                    Spacer()
                }
            }
            
            // bottom
            if let bottomItems = viewModel.bottom {
                
                VStack {
                    
                    Spacer()
                    
                    ForEach(bottomItems) { item in
                        
                        switch item {
                        case let continueViewModel as PaymentsContinueButtonView.ViewModel:
                                PaymentsContinueButtonView(viewModel: continueViewModel)
                            
                        case let amountViewModel as PaymentsAmountView.ViewModel:
                                PaymentsAmountView(viewModel: amountViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
                    .modifier(BottomBackgroundModifier())
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: PaymentsOperationViewBottomHeightPreferenceKey.self, value: proxy.size)
                        }
                    )
                    .onPreferenceChange(PaymentsOperationViewBottomHeightPreferenceKey.self, perform: { value in
                        
                        withAnimation {
                            self.bottomSize = value
                        }
                    })
                }
            }
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case let .confirm(confirmViewModel):
                        PaymentsOperationView(viewModel: confirmViewModel)
                    }
                }
            }
            
            Color.clear
                .sheet(item: $viewModel.sheet) { sheet in
                    
                    switch sheet.type {
                    case let .contacts(contactsViewModel):
                        ContactsView(viewModel: contactsViewModel)
                    }
                }
            
            Color.clear
                .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in

                    switch bottomSheet.type {
                    case .popUp(let popUpVewModel):
                        PaymentsPopUpSelectView(viewModel: popUpVewModel)
                    
                    case .antifraud(let antifraudViewModel):
                        PaymentsAntifraudView(viewModel: antifraudViewModel)
                
                    case .hint(let hintViewModel):
                        HintView(viewModel: hintViewModel)
                    }
                }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBar(with: viewModel.navigationBar)
        .modifier(SpinnerViewModifier(spinnerViewModel: $viewModel.spinner))
    }
}

extension PaymentsOperationView {
    
    struct SpinnerViewModifier: ViewModifier {
        
        @Binding var spinnerViewModel: SpinnerView.ViewModel?
        
        func body(content: Content) -> some View {
            
            ZStack {
                
                content
                
                if let spinnerViewModel = spinnerViewModel{
                    
                    SpinnerView(viewModel: spinnerViewModel)
                        .zIndex(1)
                }
            }
        }
    }
    
    struct TopBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
        
            content
                .background(Color.white.opacity(0.95).ignoresSafeArea(.container, edges: .top))
        }
    }
    
    struct BottomBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
            
            content
                .background(Color.white)
        }
    }
}

//MARK: - Preference Keys

struct PaymentsOperationViewTopHeightPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        _ = nextValue()
    }
}

struct PaymentsOperationViewBottomHeightPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        _ = nextValue()
    }
}

struct PaymentsOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            NavigationView {
                PaymentsOperationView(viewModel: .sampleContinue)
            }
            
            NavigationView {
                PaymentsOperationView(viewModel: .sampleAmount)
            }
        }
    }
}

extension PaymentsOperationViewModel {
    
    static let sampleContinue: PaymentsOperationViewModel = {
        
        let topItems = [PaymentsSwitchView.ViewModel.sample]
        let contentItems = [PaymentsSelectView.ViewModel.selectedStateMock, PaymentsInfoView.ViewModel.sample, PaymentsNameView.ViewModel.normal, PaymentsNameView.ViewModel.edit, PaymentsProductView.ViewModel.sample, PaymentsInfoView.ViewModel.sample]
        
        let bottomItems = [PaymentsContinueButtonView.ViewModel.sampleInactive]
        
        return PaymentsOperationViewModel(navigationBar: .init(title: "Налоги и услуги"), top: topItems, content: contentItems, bottom: bottomItems, link: nil, bottomSheet: nil, operation: .emptyMock, model: .emptyMock, closeAction: {})
    }()
    
    static let sampleAmount: PaymentsOperationViewModel = {
        
        let topItems = [PaymentsSwitchView.ViewModel.sample]
        let contentItems = [PaymentsSelectView.ViewModel.selectedStateMock, PaymentsInfoView.ViewModel.sample, PaymentsNameView.ViewModel.normal, PaymentsNameView.ViewModel.edit, PaymentsProductView.ViewModel.sample]
        let bottomItems = [PaymentsAmountView.ViewModel.amount]
        
        return PaymentsOperationViewModel(navigationBar: .init(title: "Налоги и услуги"), top: topItems, content: contentItems, bottom: bottomItems, link: nil, bottomSheet: nil, operation: .emptyMock, model: .emptyMock, closeAction: {})
    }()
}

