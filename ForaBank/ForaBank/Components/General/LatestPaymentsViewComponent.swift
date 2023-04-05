//
//  LatestPaymentsViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 17.10.2022.
//

import SwiftUI
import Combine

extension LatestPaymentsView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var items: [ItemViewModel]
        let isBaseButtons: Bool
        let filter: Filter?

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(_ model: Model, items: [LatestPaymentsView.ViewModel.ItemViewModel], isBaseButtons: Bool, filter: Filter?) {
            
            self.model = model
            self.items = items
            self.isBaseButtons = isBaseButtons
            self.filter = filter
        }
        
        convenience init(_ model: Model, isBaseButtons: Bool = true, filter: Filter? = nil) {
            
            self.init(model, items: Array(repeating: .placeholder(.init()), count: 4), isBaseButtons: isBaseButtons, filter: filter)
            
            bind()
        }
        
        func bind() {
            
            model.latestPayments
                .combineLatest(model.latestPaymentsUpdating)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] latestPayments, isUpdating in
                    
                    var latestPaymentsFiltered = latestPayments
                    
                    if let filter = filter {
                        
                        switch filter {
                        case let .including(including):
                            latestPaymentsFiltered = latestPayments.filter({ including.contains($0.type) })
                            
                        case let .excluding(excluding):
                            latestPaymentsFiltered = latestPayments.filter({ excluding.contains($0.type) == false })
                        }
                    }
                    
                    var items = Self.itemsReduce(model: model, latest: latestPaymentsFiltered, isUpdating: isUpdating, action: { [weak self] itemId in
                        
                        if let item = latestPayments.first(where: {$0.id == itemId}) {
                            
                            return { self?.action.send(LatestPaymentsViewModelAction.ButtonTapped.LatestPayment(latestPayment: item))}
                        }
                        
                        return {}
                    })
                    
                    if isBaseButtons == true {
                        
                        let templatesButton = Self.createTemplateButton { [weak self] in
                            
                            self?.action.send(LatestPaymentsViewModelAction.ButtonTapped.Templates())
                        }
                        
                        let currencyWalletButton = Self.createCurrencyWalletButton { [weak self] in
                            
                            self?.action.send(LatestPaymentsViewModelAction.ButtonTapped.CurrencyWallet())
                        }
                        
                        items.insert(contentsOf: [templatesButton, currencyWalletButton], at: 0)
                    }
                    
                    withAnimation {
                        self.items = items
                    }
                    
                }.store(in: &bindings)
        }

        static func itemsReduce(model: Model, latest: [LatestPaymentData], isUpdating: Bool, action: (LatestPaymentData.ID) -> () -> Void) -> [ItemViewModel] {
            
            var updatedItems = [ItemViewModel]()
            
            let latestPaymentsItems = latest.map { item in
                
                ItemViewModel.latestPayment(.init(data: item, model: model, action: action(item.id)))
            }

            if isUpdating {
                
                if latest.isEmpty {
                    
                    updatedItems.append(contentsOf: Array(repeating: .placeholder(.init()), count: 4))
                    
                } else {
                    
                    updatedItems.append(.placeholder(.init()))
                    updatedItems.append(contentsOf:  latestPaymentsItems)
                }
                
            } else {
                
                updatedItems.append(contentsOf: latestPaymentsItems)
            }
            
            return updatedItems
        }
        
        static func createTemplateButton(action: @escaping () -> Void) -> ItemViewModel {
            
            let buttonViewModel = LatestPaymentButtonVM(id: 0,
                                                        avatar: .icon(.ic24Star, .iconBlack),
                                                        topIcon: nil,
                                                        description: "Шаблоны",
                                                        action: action)
            
            return .templates(buttonViewModel)
        }
        
        static func createCurrencyWalletButton(action: @escaping () -> Void) -> ItemViewModel {
            
            let buttonViewModel = LatestPaymentButtonVM(id: -1,
                                                        avatar: .icon(.ic24CurrencyExchange, .iconBlack),
                                                        topIcon: nil,
                                                        description: "Обмен валют",
                                                        action: action)
            
            return .templates(buttonViewModel)
        }
    }
}

//MARK: - Types

extension LatestPaymentsView.ViewModel {
    
    enum Filter {
        
        case including(Set<LatestPaymentData.Kind>)
        case excluding(Set<LatestPaymentData.Kind>)
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
}

//MARK: LatestPaymentButtonVM init

extension LatestPaymentsView.ViewModel.LatestPaymentButtonVM {
    
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
            let phoneFormatter = PhoneNumberKitFormater()
            
            self.avatar = avatar(for: phoneNumberRu) ?? .icon(data.type.defaultIcon, .iconGray)
            self.topIcon = model.dictionaryBank(for: paymentData.bankId)?.svgImage.image
            self.description = fullName(for: phoneNumberRu)
            ?? (paymentData.phoneNumber.isEmpty
                ? data.type.defaultName : phoneFormatter.format(phoneNumberRu))
            
        case (.outside, let paymentData as PaymentServiceData):
            
            let firstLogo = model.dictionaryAnywayOperator(for: paymentData.puref)?.logotypeList.first
            let image = firstLogo?.svgImage?.image ?? data.type.defaultIcon
            self.avatar = .icon(image, .iconGray)
            
            self.description = paymentData.lastPaymentName ?? ""
            
            if let countryId = paymentData.additionalList.first(where: { $0.isTrnPickupPoint } )?.fieldValue,
               let country = model.countriesList.value.first(where: { $0.id == countryId } ),
               let image = country.svgImage?.image {
                
                self.topIcon = image
            } else {
                
                self.topIcon = nil
            }
                
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
                let phoneFormatter = PhoneNumberKitFormater()
                
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

//MARK: - Action PTSectionLatestPaymentsViewAction

enum LatestPaymentsViewModelAction {
    
    enum ButtonTapped {
        
        struct Templates: Action {}
        
        struct CurrencyWallet: Action {}
        
        struct LatestPayment: Action {
            
            let latestPayment: LatestPaymentData
        }
    }
}

//MARK: - View

struct LatestPaymentsView: View {
    
    @ObservedObject var viewModel: LatestPaymentsView.ViewModel
    
    var body: some View {
        
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
                
            }
            .padding(.leading, 8)
        }
    }
}

//MARK: - PlaceholderView

extension LatestPaymentsView {
    
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

extension LatestPaymentsView {
    
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



struct LatestPaymentsViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        LatestPaymentsView(viewModel: .init(.emptyMock, items: [], isBaseButtons: true, filter: nil))
    }
}
