//
//  ConsentListPrototypeView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

import SwiftUI

struct ConsentListPrototypeView: View {
    
    @State private var flow: Flow = .expanded_serverError
    
    var body: some View {
        
        ConsentListWrapperView(viewModel: .init(
            initialState: flow.initialState,
            reduce: flow.reducer.reduce(_:_:_:)
        ))
        .padding(.top, 64)
        .overlay(alignment: .topTrailing, content: picker)
    }
    
    private func picker() -> some View {
        
        Picker("Select Flow", selection: $flow) {
            
            ForEach(Flow.allCases, id: \.self) {
                
                Text($0.rawValue)
                    .tag($0)
            }
        }
        .pickerStyle(.menu)
    }
}

private extension ConsentListPrototypeView {
    
    enum Flow: String, CaseIterable {
        
        case collapsedEmptyConsent_success
        case collapsedEmptyConsent_serverError
        case collapsedEmptyConsent_connectivityError
        
        case collapsedNonEmptyConsent_success
        case collapsedNonEmptyConsent_serverError
        case collapsedNonEmptyConsent_connectivityError
        
        case expanded_success
        case expanded_serverError
        case expanded_connectivityError
        
        case collapsedError
        case expandedError
    }
}

private extension ConsentListPrototypeView.Flow {
    
    var initialState: ConsentListState {
        
        switch self {
        case .collapsedEmptyConsent_success,
                .collapsedEmptyConsent_serverError,
                .collapsedEmptyConsent_connectivityError:
            return .collapsedEmpty
            
        case .collapsedNonEmptyConsent_success,
                .collapsedNonEmptyConsent_serverError,
                .collapsedNonEmptyConsent_connectivityError:
            return .collapsedPreview
            
        case .expanded_success,
                .expanded_serverError,
                .expanded_connectivityError:
            return .expanded(.preview)
            
        case .collapsedError:
            return .failure(.collapsedError)
            
        case .expandedError:
            return .failure(.expandedError)
        }
    }
    
    var reducer: ConsentListReducer {
        
        .init(
            availableBanks: .preview,
            changeConsentList: { _, completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(changeConsentListResponse)
                }
            }
        )
    }
    
    var changeConsentListResponse: ConsentListReducer.ChangeConsentListResponse {
        
        switch self {
        case .collapsedEmptyConsent_success,
                .collapsedNonEmptyConsent_success,
                .expanded_success:
            return .success
            
        case .collapsedEmptyConsent_serverError,
                .collapsedNonEmptyConsent_serverError,
                .expanded_serverError:
            return .serverError("Возникла техническая ошибка (код 4044). Свяжитесь с поддержкой банка для уточнения")
            
        case .collapsedEmptyConsent_connectivityError,
                .collapsedNonEmptyConsent_connectivityError,
                .expanded_connectivityError:
            return .connectivityError
            
        case .collapsedError:
            fatalError("impossible")
            
        case .expandedError:
            fatalError("impossible")
        }
    }
}

struct ConsentListPrototypeWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ConsentListPrototypeView()
    }
}
