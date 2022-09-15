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
    
    init(iconType: IconTypeViewModel, title: String?, amount: String?, service: ServiceViewModel?, options: [OptionViewModel]?, logo: LogoIconViewModel?, warningTitle: String?, optionButtons: [PaymentsSuccessOptionButtonViewModel], repeatButton: ButtonSimpleView.ViewModel?, actionButton: ButtonSimpleView.ViewModel, model: Model = .emptyMock) {
        
        self.iconType = iconType
        self.title = title
        self.warningTitle = warningTitle
        self.amount = amount
        self.service = service
        self.options = options
        self.logo = logo
        self.optionButtons = optionButtons
        self.repeatButton = repeatButton
        self.actionButton = actionButton
        self.model = model
    }
    
    convenience init(_ model: Model, iconType: IconTypeViewModel, paymentSuccess: Payments.Success, dismissAction: @escaping () -> Void) {
        
        let amount = NumberFormatter.currency(paymentSuccess.amount)
        
        self.init(iconType: iconType, title: paymentSuccess.status.description, amount: amount, service: nil, options: nil, logo: .init(title: "сбп", image: paymentSuccess.icon?.image ?? .ic40Sbp), warningTitle: nil, optionButtons: [], repeatButton: nil, actionButton: .init(title: "На главную", style: .red, action: dismissAction), model: model)
    }
    
    convenience init(_ model: Model, iconType: IconTypeViewModel, title: String, amount: Double, service: ServiceViewModel? = nil, optionButtons: [PaymentsSuccessOptionButtonViewModel], logo: LogoIconViewModel? = nil, repeatButton: ButtonSimpleView.ViewModel? = nil, dismissAction: @escaping () -> Void) {
        
        let amount = NumberFormatter.currency(amount)
        
        self.init(iconType: iconType, title: title, amount: amount, service: service, options: nil, logo: logo, warningTitle: nil, optionButtons: optionButtons, repeatButton: repeatButton, actionButton: .init(title: "На главную", style: .red, action: dismissAction), model: model)
    }

    convenience init(_ model: Model, iconType: IconTypeViewModel, title: String?, amount: Double?, options: [OptionViewModel]?, logo: LogoIconViewModel?, warningTitle: String?, optionButtons: [PaymentsSuccessOptionButtonViewModel], dismissAction: @escaping () -> Void) {
        
        let amount = NumberFormatter.currency(amount)
        
        self.init(iconType: iconType, title: title, amount: amount, service: nil, options: options, logo: logo, warningTitle: warningTitle, optionButtons: optionButtons, repeatButton: nil, actionButton: .init(title: "На главную", style: .red, action: dismissAction), model: model)
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
        
        var size: CGSize {
            
            switch self {
            case .success: return .init(width: 40, height: 28)
            case .accepted: return .init(width: 40, height: 40)
            case .transfer: return .init(width: 18, height: 21)
            case .error: return .init(width: 40, height: 40)
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
