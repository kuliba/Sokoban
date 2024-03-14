//
//  ContentView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 01.03.2024.
//

import SwiftUI
import ProductProfileComponents
import ProductProfile
import RxViewModel

typealias ProductProfileViewModel = RxViewModel<ProductProfileNavigation.State, ProductProfileNavigation.Event, ProductProfileNavigation.Effect>

struct ContentView: View {
    
    let buttons: [CardGuardianState._Button]
    let topUpCardButtons: [TopUpCardState.PanelButton]
    @StateObject private var viewModel: ProductProfileViewModel
    
    init(
        buttons: [CardGuardianState._Button],
        topUpCardButtons: [TopUpCardState.PanelButton],
        accountInfoPanelButtons: [AccountInfoPanelState.PanelButton],
        accountDetails: [ListItem],
        cardDetails: [ListItem],
        sheetButtons: [ProductDetailsSheetState.PanelButton]
    ) {
        self.buttons = buttons
        self.topUpCardButtons = topUpCardButtons
        self._viewModel = .init(
            wrappedValue: .preview(
                buttons: buttons,
                topUpCardButtons: topUpCardButtons,
                accountInfoPanelButtons: accountInfoPanelButtons,
                accountDetails: accountDetails,
                detailsSheetButtons: sheetButtons, 
                cardDetails: cardDetails
            )
        )
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                VStack {
                    
                    ActivateSliderWrapperView(
                        viewModel: .init(
                            initialState: .initialState,
                            reduce: CardActivateReducer.reduceForPreview(),
                            handleEffect: CardActivateEffectHandler.handleEffectActivateSuccess()),
                        config: .default)
                    .padding()
                }
                .background(.gray)
                
                VStack {
                    
                    ActivateSliderWrapperView(
                        viewModel: .init(
                            initialState: .initialState,
                            reduce: CardActivateReducer.reduceForPreview(),
                            handleEffect: CardActivateEffectHandler.handleEffectActivateFailure()),
                        config: .default)
                    .padding()
                }
                .background(.gray)
                
                ZStack {
                    
                    NavigationLink(destination: destination()) {
                        
                        Image(systemName: "person.text.rectangle.fill")
                            .renderingMode(.original)
                            .foregroundColor(Color(.systemMint))
                            .font(.system(size: 120))
                    }
                    
                    CvvButtonView(
                        state: viewModel.state.alert,
                        event: {
                            
                            switch $0 {
                            case .showAlert:
                                viewModel.event(.showAlert(.alertCVV()))
                                
                            case .closeAlert:
                                viewModel.event(.closeAlert)
                            }
                        }
                    )
                    .offset(x: 40, y: 30)
                    
                    CvvCardBlockedView(
                        state: viewModel.state.alert,
                        event: {
                            
                            switch $0 {
                            case .showAlert:
                                viewModel.event(.showAlert(.alertCardBlocked()))
                                
                            case .closeAlert:
                                viewModel.event(.closeAlert)
                            }
                        }
                    )
                    .offset(x: -40, y: 30)
                }
            }
        }
    }
    
    private func destination() -> some View {
        
        VStack() {
            
            ControlButtonView.init(
                state: viewModel.state,
                event: viewModel.event
            )
            
            TopUpCardView.init(
                state: viewModel.state,
                event: viewModel.event
            )
            
            AccountInfoPanelView.init(
                state: viewModel.state,
                event: viewModel.event
            )
        }
        .padding()
    }
}

#Preview {
    ContentView(
        buttons: .preview,
        topUpCardButtons: .previewRegular,
        accountInfoPanelButtons: .previewRegular,
        accountDetails: .accountItems,
        cardDetails: .cardItems, 
        sheetButtons: .previewRegular
    )
}
