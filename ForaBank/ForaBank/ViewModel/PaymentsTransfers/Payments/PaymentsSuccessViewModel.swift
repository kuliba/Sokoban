//
//  PaymentsSuccessViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI
import Combine

class PaymentsSuccessViewModel: ObservableObject, Identifiable {
    
    @Published var optionButtons: [PaymentsSuccessOptionButtonViewModel]
    
    let id = UUID()
    let iconType: IconTypeViewModel
    let title: String?
    let warningTitle: String?
    let amount: String?
    let service: ServiceViewModel?
    let options: [OptionViewModel]?
    let logo: LogoIconViewModel?
    
    let repeatButton: ButtonSimpleView.ViewModel?
    let actionButton: ButtonSimpleView.ViewModel
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(model: Model = .emptyMock,
         iconType: IconTypeViewModel,
         title: String? = nil,
         amount: String? = nil,
         service: ServiceViewModel? = nil,
         options: [OptionViewModel]? = nil,
         logo: LogoIconViewModel? = nil,
         warningTitle: String? = nil,
         repeatButton: ButtonSimpleView.ViewModel? = nil,
         optionButtons: [PaymentsSuccessOptionButtonViewModel],
         actionButton: ButtonSimpleView.ViewModel) {
        
        self.model = model
        self.iconType = iconType
        self.title = title
        self.amount = amount
        self.service = service
        self.options = options
        self.logo = logo
        self.warningTitle = warningTitle
        self.repeatButton = repeatButton
        self.optionButtons = optionButtons
        self.actionButton = actionButton
    }
    
    convenience init(_ model: Model, dismissAction: @escaping () -> Void) {
        self.init(model: model, iconType: .success, optionButtons: [], actionButton: .init(title: "На главную", style: .red, action: dismissAction))
    }
    
    convenience init(_ model: Model, iconType: IconTypeViewModel, paymentSuccess: Payments.Success, dismissAction: @escaping () -> Void) {
        
        let amount = model.amountFormatted(amount: paymentSuccess.amount, currencyCode: nil, style: .normal)
        
        self.init(model: model, iconType: iconType, title: paymentSuccess.status.description, amount: amount, logo: .init(title: "сбп", image: paymentSuccess.icon?.image ?? .ic40Sbp), optionButtons: [], actionButton: .init(title: "На главную", style: .red, action: dismissAction))
    }
}

extension PaymentsSuccessViewModel {
    
    enum IconTypeViewModel {
        
        case success
        case accepted
        case transfer
        case error
        
        var image: Image {
            
            switch self {
            case .success: return .ic48Check
            case .accepted: return .ic48Clock
            case .transfer: return .ic48UploadToAccount
            case .error: return .ic48Close
            }
        }
        
        var color: Color {
            
            switch self {
            case .success: return .systemColorActive
            case .accepted: return .systemColorWarning
            case .transfer: return .systemColorWarning
            case .error: return .systemColorError
            }
        }
    }
    
    struct LogoIconViewModel {
        
        let title: String
        let image: Image
    }
    
    struct LogoIconViewModel2 {
        
        let title: String
        let image: Image
    }
    
    struct ServiceViewModel {
        
        let title: String
        let description: String
    }
    
    struct OptionViewModel: Identifiable {
    
        let id: UUID = .init()
        let image: Image
        let title: String
        let subTitle: String?
        let description: String
    }
}

class PaymentsSuccessOptionButtonViewModel: Identifiable {
    
    let id: UUID = .init()
    let icon: Image
    let title: String
    let action: () -> Void
    
    init(icon: Image, title: String, action: @escaping () -> Void) {
        
        self.icon = icon
        self.title = title
        self.action = action
    }
}
