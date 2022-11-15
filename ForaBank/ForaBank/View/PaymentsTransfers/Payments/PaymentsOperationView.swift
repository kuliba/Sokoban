//
//  PaymentsOperationViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.02.2022.
//

import SwiftUI
import Combine

struct PaymentsOperationView: View {
    
    @ObservedObject var viewModel: PaymentsOperationViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var topSize: CGSize = .zero
    @State private var bottomSize: CGSize = .zero
    
    var body: some View {
        
        ZStack {

            // content
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 20) {
                    
                    Color.clear
                        .frame(height: topSize.height)
                    
                    ForEach(viewModel.content) { item in
                        
                        switch item {
                        case let selectViewModel as PaymentsSelectView.ViewModel:
                            PaymentsSelectView(viewModel: selectViewModel)
                            
                        case let selectViewModels as PaymentsSelectSimpleView.ViewModel:
                            PaymentsSelectSimpleView(viewModel: selectViewModels)
                            
                        case let switchViewModel as PaymentsSwitchView.ViewModel:
                            PaymentsSwitchView(viewModel: switchViewModel)
                            
                        case let inputViewModel as PaymentsInputView.ViewModel:
                            PaymentsInputView(viewModel: inputViewModel)
                            
                        case let infoViewModel as PaymentsInfoView.ViewModel:
                            PaymentsInfoView(viewModel: infoViewModel)
                            
                        case let nameViewModel as PaymentsNameView.ViewModel:
                            PaymentsNameView(viewModel: nameViewModel)
                            
                        case let cardViewModel as PaymentsProductView.ViewModel:
                            PaymentsProductView(viewModel: cardViewModel)
                            
                        case let codeViewModel as PaymentsCodeView.ViewModel:
                            PaymentsCodeView(viewModel: codeViewModel)
                            
                        case let additionButtonViewModel as PaymentsSpoilerButtonView.ViewModel:
                            PaymentsSpoilerButtonView(viewModel: additionButtonViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
                    
                    Color.clear
                        .frame(height: bottomSize.height)
                }
                
            }
            .padding(.horizontal, 20)
            
            // top
            if let topItems = viewModel.top {
                
                VStack {
                    
                    ForEach(topItems) { item in
                        
                        switch item {
                        case let switchViewModel as PaymentsSwitchView.ViewModel:
                            PaymentsSwitchView(viewModel: switchViewModel)
                                .padding(.horizontal, 20)
                            
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
                    .onPreferenceChange(PaymentsOperationViewTopHeightPreferenceKey.self, perform: { self.topSize = $0 })
                    
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
                    .onPreferenceChange(PaymentsOperationViewBottomHeightPreferenceKey.self, perform: { self.bottomSize = $0 })
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
        }
        .navigationBarTitle(Text(viewModel.header.title), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }, label: {
            viewModel.header.backButtonIcon }))
        .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in

            switch bottomSheet.type {
            case .popUp(let popUpVewModel):
                PaymentsPopUpSelectView(viewModel: popUpVewModel)
            }
        }
    }
}

extension PaymentsOperationView {
    
    struct TopBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
        
            content
                .background(Color.white.opacity(0.95).ignoresSafeArea(.container, edges: .top))
        }
    }
    
    struct BottomBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
            
            if #available(iOS 15.0, *) {
                
                content
                    .background(.ultraThinMaterial, ignoresSafeAreaEdges: .bottom)
                
            } else {
                
                content
                    .background(Color.white.opacity(0.95).ignoresSafeArea(.container, edges: .bottom))
            }
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
        
        let bottomItems = [PaymentsContinueButtonView.ViewModel.sample]
        
        return PaymentsOperationViewModel(header: .init(title: "Налоги и услуги"), top: topItems, content: contentItems, bottom: bottomItems, link: nil, bottomSheet: nil, operation: .emptyMock, model: .emptyMock)
    }()
    
    static let sampleAmount: PaymentsOperationViewModel = {
        
        let topItems = [PaymentsSwitchView.ViewModel.sample]
        let contentItems = [PaymentsSelectView.ViewModel.selectedStateMock, PaymentsInfoView.ViewModel.sample, PaymentsNameView.ViewModel.normal, PaymentsNameView.ViewModel.edit, PaymentsProductView.ViewModel.sample]
        let bottomItems = [PaymentsAmountView.ViewModel.amount]
        
        return PaymentsOperationViewModel(header: .init(title: "Налоги и услуги"), top: topItems, content: contentItems, bottom: bottomItems, link: nil, bottomSheet: nil, operation: .emptyMock, model: .emptyMock)
    }()
}

