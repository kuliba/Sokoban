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
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            // top
            if let topItems = viewModel.top {
                
                ForEach(topItems, content: PaymentsGroupView.groupView(for:))
                    .padding(.bottom, 16)
            }
            
            //content
            ScrollViewReader { reader in
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 16) {
                        
                        ForEach(viewModel.feed, content: PaymentsGroupView.groupView(for:))
                        
                        Color.clear
                            .frame(height: 0)
                            .id("bottom")
                    }
                    
                }
                .transition(.move(edge: .bottom))
                .onChange(of: viewModel.feed.count) { _ in

                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(310)) {
                        
                        withAnimation {
                            reader.scrollTo("bottom")
                        }
                    }
                }
            }
            
            Spacer()
            
            // bottom
            if let bottomItems = viewModel.bottom {
                
                ForEach(bottomItems, content: PaymentsGroupView.groupView(for:))
                    .padding(.bottom, 24)
            }
            
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                    case let .success(successViewModel):
                        PaymentsSuccessView(viewModel: successViewModel)
                            .navigationBarBackButtonHidden()
                        
                    case let .confirm(confirmViewModel):
                        PaymentsOperationView(viewModel: confirmViewModel)
                    }
                }
            }
            .frame(height: 0)
            
            Color.clear
                .frame(height: 0)
                .sheet(item: $viewModel.sheet) { sheet in
                    
                    switch sheet.type {
                    case let .contacts(contactsViewModel):
                        ContactsView(viewModel: contactsViewModel)
                    }
                }
            
            Color.clear
                .frame(height: 0)
                .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in
                    
                    switch bottomSheet.type {
                    case .popUp(let popUpVewModel):
                        PaymentsPopUpSelectView(viewModel: popUpVewModel)
                        
                    case .antifraud(let antifraudViewModel):
                        if #available(iOS 15.0, *) {
                        PaymentsAntifraudView(viewModel: antifraudViewModel)
                            .interactiveDismissDisabled()
                        } else {
                            PaymentsAntifraudView(viewModel: antifraudViewModel)
                        }
                        
                    case .hint(let hintViewModel):
                        HintView(viewModel: hintViewModel)
                        
                    case .changeName(let changeNameViewModel):
                        TemplatesListView.RenameTemplateItemView(viewModel: changeNameViewModel)
                    }
                }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBar(with: viewModel.navigationBar)
        .modifier(SpinnerViewModifier(spinnerViewModel: $viewModel.spinner))
    }
}


//MARK: - Modifiers

extension PaymentsOperationView {
    
    @ViewBuilder
    func groupView(for groupViewModel: PaymentsGroupViewModel) -> some View {
        
        switch groupViewModel {
        case let contactGroupViewModel as PaymentsContactGroupViewModel:
            PaymentsContactGroupView(viewModel: contactGroupViewModel)
            
        case let infoGroupViewModel as PaymentsInfoGroupViewModel:
            PaymentsInfoGroupView(viewModel: infoGroupViewModel)
            
        case let spoilerGroupViewModel as PaymentsSpoilerGroupViewModel:
            PaymentsSpoilerGroupView(viewModel: spoilerGroupViewModel)
            
        default:
            PaymentsGroupView(viewModel: groupViewModel)
        }
    }
}

//MARK: - Modifiers

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
}

//MARK: - Preview

struct PaymentsOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsOperationView(viewModel: .sampleContinue)
            
            PaymentsOperationView(viewModel: .sampleAmount)
        }
    }
}

//MARK: - Preview Content

extension PaymentsOperationViewModel {
    
    static let sampleContinue: PaymentsOperationViewModel = {
        
        let topItems = [PaymentSelectDropDownView.ViewModel.sample]
        
        let contentItems = [PaymentsSelectView.ViewModel.selectedDisabled, PaymentsInfoView.ViewModel.sample,  PaymentsProductView.ViewModel.sample]
        
        let bottomItems = [PaymentsButtonView.ViewModel.sampleParam]
        
        return PaymentsOperationViewModel(
            navigationBar: .init(title: "Налоги и услуги"),
            top: [PaymentsGroupViewModel(items: topItems)],
            feed: [PaymentsGroupViewModel(items: contentItems)],
            bottom: [PaymentsGroupViewModel(items: bottomItems)],
            closeAction: {})
    }()
    
    static let sampleAmount: PaymentsOperationViewModel = {
        
        let topItems = [PaymentSelectDropDownView.ViewModel.sample]
        
        let contentItems = [PaymentsSelectView.ViewModel.selectedDisabled, PaymentsInfoView.ViewModel.sample,  PaymentsProductView.ViewModel.sample]
        
        let bottomItems = [PaymentsAmountView.ViewModel.amountParameter]
        
        return PaymentsOperationViewModel(
            navigationBar: .init(title: "Налоги и услуги"),
            top: [PaymentsGroupViewModel(items: topItems)],
            feed: [PaymentsGroupViewModel(items: contentItems)],
            bottom: [PaymentsGroupViewModel(items: bottomItems)],
            closeAction: {})
    }()
}
