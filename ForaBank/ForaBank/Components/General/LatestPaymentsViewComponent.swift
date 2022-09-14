//
//  PTSectionLatestPaymentsViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI
import Combine
import Shimmer

//MARK: Section ViewModel

extension LatestPaymentsViewComponent {
    
    class ViewModel: PaymentsTransfersSectionViewModel {
        
        @Published var items: [ItemViewModel]
        
        override var type: PaymentsTransfersSectionType { .latestPayments }
        private let model: Model
        
        private var bindings = Set<AnyCancellable>()
        
        init(items: [ItemViewModel], model: Model) {
            self.items = items
            self.model = model
            super.init()
        }
        
        init(model: Model) {
            self.items = []
            self.model = model
            super.init()
            bind()
        }
        
        enum ItemViewModel: Identifiable {

            case templates(LatestPaymentButtonVM)
            case currencyWallet(LatestPaymentButtonVM)
            case latestPayment(LatestPaymentButtonVM)
            case placeholder(PlaceholderViewModel)

            var id: String {
            
               switch self {
               case let .templates(templatesButtonViewModel): return String(templatesButtonViewModel.id)
               case let .currencyWallet(currencyButtonViewModel): return String(currencyButtonViewModel.id)
               case let .latestPayment(latestPaymentButtonVM): return String(latestPaymentButtonVM.id)
               case let .placeholder(placeholderViewModel): return placeholderViewModel.id.uuidString
               }
            }
        }

        struct PlaceholderViewModel: Identifiable {

            let id = UUID()
        }
        
        struct LatestPaymentButtonVM: Identifiable {
               
            let id: LatestPaymentData.ID
            let avatar: Avatar
            let topIcon: Image?
            let description: String
            let action: () -> Void

            enum Avatar {
                case image(Image)
                case text(String)
                case icon(Image, Color)
            }
        }
        
        func bind() {
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                
                    case let payload as ModelAction.Contacts.PermissionStatus.Update:
                    
                        switch payload.status {
                        case .available:
                       
                            if !model.latestPayments.value.isEmpty {
                                
                                // temporally removed taxAndStateService from list
                                let latestPaymentsFilterred = model.latestPayments.value.filter({ $0.type != .taxAndStateService })
                            
                                withAnimation(.easeInOut(duration: 1)) {
                                    self.items = itemsReduce(latest: latestPaymentsFilterred)
                                }
                            }
                        
                        default: break
                        }
                    default: break
                    }
                    
            }.store(in: &bindings)
            
            model.latestPayments
                .combineLatest(model.latestPaymentsUpdating)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                    
                    let latestPayments = data.0
                    let isLatestPaymentsUpdating = data.1
                    
                    // temporally removed taxAndStateService from list
                    let latestPaymentsFilterred = latestPayments.filter({ $0.type != .taxAndStateService })
                    
                    withAnimation(.easeInOut(duration: 1)) {
                        self.items = itemsReduce(latest: latestPaymentsFilterred,
                                                 isUpdating: isLatestPaymentsUpdating)
                    }
                
            }.store(in: &bindings)
            
        }
        
        func itemsReduce(latest: [LatestPaymentData],
                         isUpdating: Bool = false) -> [ItemViewModel] {
            
            var updatedItems = [ItemViewModel]()
            let baseButtons = self.baseButtons.map { ItemViewModel.templates($0) }
            
            let latestPaymentsItems = latest.map { item in
               
                ItemViewModel
                    .latestPayment(
                        .init(data: item,
                              model: self.model,
                              action: { [weak self] in
                                        self?.action.send(PTSectionLatestPaymentsViewAction
                                                            .ButtonTapped
                                                            .LatestPayment(latestPayment: item)) } ))
            }
        
            if isUpdating {
     
                 if latest.isEmpty {
                     
                     updatedItems.append(contentsOf: baseButtons)
                     updatedItems.append(contentsOf: Array(repeating: .placeholder(.init()), count: 4))
                     
                 } else {
                     
                     updatedItems.append(contentsOf: baseButtons)
                     updatedItems.append(.placeholder(.init()))
                     updatedItems.append(contentsOf:  latestPaymentsItems)
                     
                 }
             
            } else {

                      updatedItems.append(contentsOf: baseButtons)
                      updatedItems.append(contentsOf: latestPaymentsItems)
            }
            
            return updatedItems
            
        }
        
        lazy var baseButtons: [LatestPaymentButtonVM] = {
            [
                .init(id: 0,
                      avatar: .icon(.ic24Star, .iconBlack),
                      topIcon: nil,
                      description: "Шаблоны",
                      action: { [weak self] in
                          self?.action.send(PTSectionLatestPaymentsViewAction.ButtonTapped.Templates())
                      }),
                .init(id: -1,
                      avatar: .icon(.ic24CurrencyExchange, .iconBlack),
                      topIcon: nil,
                      description: "Обмен валют",
                      action: { [weak self] in
                          self?.action.send(PTSectionLatestPaymentsViewAction.ButtonTapped.CurrencyWallet())
                      })
            ]
        }()
    }
}

//MARK: - Action PTSectionLatestPaymentsViewAction

enum PTSectionLatestPaymentsViewAction {

    enum ButtonTapped {

        struct Templates: Action {}
        
        struct CurrencyWallet: Action {}

        struct LatestPayment: Action {

            let latestPayment: LatestPaymentData
        }
    }
}

//MARK: Section View

struct LatestPaymentsViewComponent: View {
    
    @ObservedObject
    var viewModel: ViewModel
    
    var body: some View {
        
        Text(viewModel.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.textH1SB24322())
            .foregroundColor(.textSecondary)
            .padding(.vertical, 16)
            .padding(.leading, 20)
        
        ScrollView(.horizontal,showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(viewModel.items) { item in
                    
                    switch item {
                    case let .templates(templateVM):
                        LatestPaymentButtonView(viewModel: templateVM)
                    
                    case let .currencyWallet(currencyWalletButtonViewModel):
                        LatestPaymentButtonView(viewModel: currencyWalletButtonViewModel)
                    
                    case let .latestPayment(latestPaymentVM):
                        LatestPaymentButtonView(viewModel: latestPaymentVM)
                        
                    case let .placeholder(placeholderVM):
                        PlaceholderView(viewModel: placeholderVM)
                            .shimmering(active: true, bounce: true)
                    }
                }
                Spacer()
            }.padding(.leading, 8)
        }
    }
}

//MARK: - PlaceholderView

extension LatestPaymentsViewComponent {
    
    struct PlaceholderView: View {
        
        let viewModel: ViewModel.PlaceholderViewModel
        
        var body: some View {
            
            VStack(alignment: .center, spacing: 8) {
                
                Circle()
                    .fill(Color.mainColorsGray.opacity(0.4))
                    .frame(width: 56, height: 56)
                
                VStack(alignment: .center, spacing: 8) {
                    
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 65, height: 8, alignment: .center)

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 45, height: 8, alignment: .center)
                }
                .foregroundColor(.mainColorsGray.opacity(0.4))
                .frame(width: 80, height: 32)
            }
            
        }
    }
}

//MARK: - LatestPaymentButtonView

extension LatestPaymentsViewComponent {
    
    struct LatestPaymentButtonView: View {
        
        let viewModel: ViewModel.LatestPaymentButtonVM
        
        var body: some View {
            
            Button(action: viewModel.action, label: {
                VStack(alignment: .center, spacing: 8) {
                    ZStack {
                        
                        Circle()
                            .fill(Color.mainColorsGrayLightest)
                            .frame(height: 56)
                            
                        switch viewModel.avatar {
                        case let .image(image):
                                   
                            image
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(height: 56)
                                    
                        case let .text(text):
                            Text(text)
                                .font(.textH4M16240())
                                .foregroundColor(.textPlaceholder)
                                    
                        case let .icon(icon, color):
                            icon
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(color)
                        }
                            
                        if let topIcon = viewModel.topIcon {
                            topIcon
                                .renderingMode(.original)
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 24, height: 24)
                                .position(x: 64, y: 12)
                        }
                        
                    }
                    
                    Text(viewModel.description)
                        .font(.textBodySR12160())
                        .lineLimit(2)
                        .foregroundColor(.textSecondary)
                        .frame(width: 80, height: 32, alignment: .top)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 80, height: 96)
            })
        }
    }

}

//MARK: default LatestPaymentButton by type

extension LatestPaymentData.Kind {
    
    var defaultName: String {
        
        switch self {
        case .country: return "За рубеж"
        case .phone: return "По телефону"
        case .service: return "Услуги ЖКХ"
        case .mobile: return "Услуги связи"
        case .internet: return "Услуги интернет"
        case .transport: return "Услуги Транспорта"
        case .taxAndStateService: return  "Госуслуги"
        case .unknown: return "Неизвестно"
        }
    }
    
    var defaultIcon: Image {
        
        switch self {
        case .country: return .ic24Globe
        case .phone: return .ic24Smartphone
        case .service: return .ic24ZKX
        case .mobile: return .ic24Smartphone
        case .internet: return .ic24Tv
        case .transport: return .ic24Car
        case .taxAndStateService: return .ic24Emblem
        case .unknown: return .ic24AlertTriangle
        }
    }
}

//MARK: LatestPaymentButtonVM init

extension LatestPaymentsViewComponent.ViewModel.LatestPaymentButtonVM {
    
    init(data: LatestPaymentData, model: Model, action: @escaping () -> Void) {
        
        func fullName(for phoneNumber: String?) -> String? {
            
            guard case .available = model.contactsPermissionStatus,
                  let phoneNumber = phoneNumber,
                  let contact = model.contact(for: phoneNumber)
            else { return nil }
            
            return contact.fullName
        }
                
        func avatar(for phoneNumber: String?) -> Self.Avatar? {
            
            guard case .available = model.contactsPermissionStatus,
                  let phoneNumber = phoneNumber,
                  let contact = model.contact(for: phoneNumber)
            else { return nil }
            
            if let avatar = contact.avatar,
               let avatarImg = Image(data: avatar.data) {
                
                return .image(avatarImg)
                
            } else if let initials = contact.initials {
                
                return .text(initials)
                
            } else {
                
                return nil
            }
        }
        
        switch (data.type, data) {
        case (.phone, let paymentData as PaymentGeneralData):
            
            let phoneNumberRu = "+7" + paymentData.phoneNumber
            let phoneFormatter = PhoneNumberFormater()
            
            self.avatar = avatar(for: phoneNumberRu) ?? .icon(data.type.defaultIcon, .iconGray)
            self.topIcon = model.dictionaryBank(for: paymentData.bankId)?.svgImage.image
            self.description = fullName(for: phoneNumberRu)
                ?? (paymentData.phoneNumber.isEmpty
                    ? data.type.defaultName : phoneFormatter.format(phoneNumberRu))
            
        case (.country, let paymentData as PaymentCountryData):

            if let phoneNumber = paymentData.phoneNumber,
               !phoneNumber.isEmpty {
            
                let phoneNumberInt = "+" + phoneNumber
                let phoneFormatter = PhoneNumberFormater()
            
                self.avatar = avatar(for: phoneNumberInt)
                                ?? (!paymentData.shortName.isEmpty
                                    ? .text(String(paymentData.shortName.first!).uppercased())
                                    : .icon(data.type.defaultIcon, .iconGray))
                self.description = fullName(for: phoneNumberInt)
                    ?? (paymentData.shortName.isEmpty
                        ? phoneFormatter.format(phoneNumberInt) : paymentData.shortName)
            } else {
                self.avatar = !paymentData.shortName.isEmpty
                                ? .text(String(paymentData.shortName.first!).uppercased())
                                : .icon(data.type.defaultIcon, .iconGray)
                self.description = paymentData.shortName.isEmpty
                                ? paymentData.type.defaultName : paymentData.shortName
            }
            self.topIcon = model.dictionaryCountry(for: paymentData.countryCode)?.svgImage?.image
                    
        case (.service, let paymentData as PaymentServiceData):
     
            if let image = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image {
                self.avatar = .image(image)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
            }
            self.description = model.dictionaryAnywayOperator(for: paymentData.puref)?.name
                                ?? data.type.defaultName
            self.topIcon = nil
                    
        case (.transport, let paymentData as PaymentServiceData):
            
            if let image = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image {
                self.avatar = .image(image)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
            }
            self.description = model.dictionaryAnywayOperator(for: paymentData.puref)?.name
                                ?? data.type.defaultName
            self.topIcon = nil
                    
        case (.internet, let paymentData as PaymentServiceData):
            
            if let image = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image {
                self.avatar = .image(image)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
            }
            self.description = model.dictionaryAnywayOperator(for: paymentData.puref)?.name
                                ?? data.type.defaultName
            self.topIcon = nil
            
        case (.mobile, let paymentData as PaymentServiceData):
                
            if let phoneNumber = paymentData.additionalList.first?.fieldValue,
               !phoneNumber.isEmpty {
                
                let phoneNumberRu = "+7" + phoneNumber
                let phoneFormatter = PhoneNumberFormater()
                
                self.avatar = avatar(for: phoneNumberRu) ?? .icon(data.type.defaultIcon, .iconGray)
                self.description = fullName(for: phoneNumberRu) ?? phoneFormatter.format(phoneNumberRu)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
                self.description = data.type.defaultName
            }
            self.topIcon = model.dictionaryAnywayOperator(for: paymentData.puref)?
                            .logotypeList.first?.svgImage?.image

                
        case (.taxAndStateService, let paymentData as PaymentServiceData):
           
            if let image = model.dictionaryAnywayOperator(for: paymentData.puref)?
                .logotypeList.first?.svgImage?.image {
                self.avatar = .image(image)
            } else {
                self.avatar = .icon(data.type.defaultIcon, .iconGray)
            }
            self.description = model.dictionaryAnywayOperator(for: paymentData.puref)?.name
                                ?? data.type.defaultName
            self.topIcon = nil
            
        default: //error matching, init default
            self.avatar = .icon(data.type.defaultIcon, .iconGray)
            self.topIcon = nil
            self.description = data.type.defaultName
        }
        
        self.action = action
        self.id = data.id
    }
            
}

//MARK: - Preview

struct PTSectionLatestPaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        LatestPaymentsViewComponent(viewModel: .sample)
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("Section LatestPayments")
    }
}
