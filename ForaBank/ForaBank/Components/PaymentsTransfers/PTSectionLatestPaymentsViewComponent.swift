//
//  PTSectionLatestPaymentsViewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 19.05.2022.
//

import SwiftUI
import Combine

//MARK: Section ViewModel

extension PTSectionLatestPaymentsView {
    
    class ViewModel: PaymentsTransfersSectionViewModel {
     
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published
        var latestPaymentsButtons: [LatestPaymentButtonVM]
        
        override var type: PaymentsTransfersSectionType { .latestPayments }
        private let model: Model
        
        private var bindings = Set<AnyCancellable>()
        
        init(latestPaymentsButtons: [LatestPaymentButtonVM], model: Model) {
            self.latestPaymentsButtons = latestPaymentsButtons
            self.model = model
            super.init()
        }
        
        init(model: Model) {
            self.latestPaymentsButtons = []
            self.model = model
            super.init()
            bind()
        }
        
        struct LatestPaymentButtonVM: Identifiable {
               
            let id = UUID()
            let image: ImageType
            let topIcon: Image?
            let description: String
            let action: () -> Void

            enum ImageType {
                case image(Image)
                case text(String)
                case icon(Image, Color)
            }
        }
        
        func bind() {
            
            model.latestPayments
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] latestPayments in
                    
                    withAnimation {
                        
                        self.latestPaymentsButtons = self.templateButton
                        
                        guard !latestPayments.isEmpty else { return }
                        
                        self.model.action.send(ModelAction.Contacts.PermissionStatus.Request())
                        for item in latestPayments {
                            
                            latestPaymentsButtons
                                .append(.init(data: item,
                                              model: self.model,
                                              action: { [weak self] in
                                                        self?.action.send(PTSectionLatestPaymentsViewAction
                                                                         .ButtonTapped
                                                                         .LatestPayment(latestPayment: item)) } ))
                        }
                    }
                }.store(in: &bindings)
        }
        
        lazy var templateButton: [LatestPaymentButtonVM] = {
            [
                .init(image: .icon(.ic24Star, .iconBlack),
                      topIcon: nil,
                      description: "Шаблоны и автоплатежи",
                      action: { [weak self] in
                          self?.action.send(PTSectionLatestPaymentsViewAction.ButtonTapped.Templates())
                      })
            ]
        }()
    }
}

//MARK: - Action PTSectionLatestPaymentsViewAction

enum PTSectionLatestPaymentsViewAction {

    enum ButtonTapped {

        struct Templates: Action {}

        struct LatestPayment: Action {

            let latestPayment: LatestPaymentData
        }
    }
}

//MARK: Section View

struct PTSectionLatestPaymentsView: View {
    
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
                ForEach(viewModel.latestPaymentsButtons) { buttonVM in
                    
                    LatestPaymentButtonView(viewModel: buttonVM)
                }
                Spacer()
            }.padding(.leading, 8)
            
        }
    }
    
}

//MARK: - LatestPaymentButtonView

extension PTSectionLatestPaymentsView {
    
    struct LatestPaymentButtonView: View {
        
        let viewModel: ViewModel.LatestPaymentButtonVM
        
        var body: some View {
            Button(action: {}, label: {
                VStack(alignment: .center, spacing: 8) {
                    ZStack {
                        
                        Circle()
                            .fill(Color.mainColorsGrayLightest)
                            .frame(height: 56)
                            .overlay13 {
                                
                                switch viewModel.image {
                                case let .image(image):
                                   
                                    image
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
                            }
                    }
                    .overlay13(alignment: .topTrailing) {
                        if let topIcon = viewModel.topIcon {
                            topIcon
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                    Text(viewModel.description)
                        .font(.textBodySR12160())
                        .lineLimit(2)
                        .foregroundColor(.textSecondary)
                        .frame(width: 80, height: 32, alignment: .center)
                        .multilineTextAlignment(.center)
                }
            })
        }
    }

}

//MARK: default LatestPaymentButton by type

extension LatestPaymentData.Kind {
    typealias ButtonVM = PTSectionLatestPaymentsView.ViewModel.LatestPaymentButtonVM
    
    var defaultButton: ButtonVM {
        switch self {
        case .country:
            return .init(image: .icon(.ic24Globe, .iconGray),
                         topIcon: nil, description: "За рубеж", action: {})
        case .phone:
            return .init(image: .icon(.ic24Smartphone, .iconGray),
                         topIcon: nil, description: "По телефону", action: {})
        case .service:
            return .init(image: .icon(.ic24ZKX, .iconGray),
                         topIcon: nil, description: "Услуги ЖКХ", action: {})
        case .mobile:
            return .init(image: .icon(.ic24Smartphone, .iconGray),
                         topIcon: nil, description: "Услуги связи", action: {})
        case .internet:
            return .init(image: .icon(.ic24Tv, .iconGray),
                         topIcon: nil, description: "Услуги интернет", action: {})
        case .transport:
            return .init(image: .icon(.ic24Car, .iconGray),
                         topIcon: nil, description: "Услуги Транспорта", action: {})
        case .taxAndStateService:
            return .init(image: .icon(.ic24Emblem, .iconGray),
                         topIcon: nil, description: "Госуслуги", action: {})
        }
    }
}

//MARK: LatestPaymentButtonVM init

extension PTSectionLatestPaymentsView.ViewModel.LatestPaymentButtonVM {
    
    init(data: LatestPaymentData, model: Model, action: @escaping () -> Void) {
        
        var image = data.type.defaultButton.image
        var topIcon = data.type.defaultButton.topIcon
        var text = data.type.defaultButton.description
        
        func mutateViewsFromContacts(by phoneNumber: String) {
            
            guard case .available = model.contactsPermissionStatus,
                  let contact = model.contact(for: phoneNumber)
            else { return }
            
            if let fullName = contact.fullName { text = fullName }
                    
            if let avatar = contact.avatar,
               let avatarImg = Image(data: avatar.data) {
                image = .image(avatarImg)
            } else {
                if let initials = contact.initials {
                    image = .text(initials)
                }
            }
        }
        
        switch (data.type, data) {
        case (.phone, let paymentData as PaymentGeneralData):
            
            text = paymentData.phoneNumber
            if let bank = model.dictionaryBank(for: paymentData.bankId) {
                topIcon = bank.svgImage.image
            }
            mutateViewsFromContacts(by: paymentData.phoneNumber)
            
        case (.country, let paymentData as PaymentCountryData):
                   
            if let firstChar = paymentData.shortName.first {
                text = paymentData.shortName
                image = .text(String(firstChar).uppercased())
            }
            if let phone = paymentData.phoneNumber {
                text = phone
                mutateViewsFromContacts(by: phone)
            }
            if let country = model.dictionaryCountry(for: paymentData.countryCode),
               let countryImg = country.svgImage?.image {
                topIcon = countryImg
            }
                    
        case (.service, let paymentData as PaymentServiceData):
                   
            text = String(paymentData.puref)
            if let oper = model.dictionaryAnywayOperator(for: paymentData.puref) {
                text = oper.name
                if let logo = oper.logotypeList.first?.svgImage?.image {
                    image = .image(logo)
                }
            }
                    
        case (.transport, let paymentData as PaymentServiceData):
            
            text = String(paymentData.puref)
            if let oper = model.dictionaryAnywayOperator(for: paymentData.puref) {
                text = oper.name
                if let logo = oper.logotypeList.first?.svgImage?.image {
                    image = .image(logo)
                }
            }
                    
        case (.internet, let paymentData as PaymentServiceData):
                  
            text = String(paymentData.puref)
            if let oper = model.dictionaryAnywayOperator(for: paymentData.puref) {
                text = oper.name
                if let logo = oper.logotypeList.first?.svgImage?.image {
                    image = .image(logo)
                }
            }
            
        case (.mobile, let paymentData as PaymentServiceData):
                
            text = String(paymentData.puref)
            if let phone = paymentData.additionalList.first?.fieldValue,
               !phone.isEmpty {
                    text = phone
                    mutateViewsFromContacts(by: phone)
            }
            if let oper = model.dictionaryAnywayOperator(for: paymentData.puref),
               let logo = oper.logotypeList.first?.svgImage?.image {
                    topIcon = logo
            }
                
        case (.taxAndStateService, let paymentData as PaymentServiceData):
            
            text = String(paymentData.puref)
            if let oper = model.dictionaryAnywayOperator(for: paymentData.puref) {
                text = oper.name
                if let logo = oper.logotypeList.first?.svgImage?.image {
                    image = .image(logo)
                }
            }
            
        default: //error matching, init default
            break
        }
        
        self.init(image: image, topIcon: topIcon, description: text, action: action)
    }
            
}

//MARK: - Preview

struct PTSectionLatestPaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PTSectionLatestPaymentsView(viewModel: .sample)
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("Section LatestPayments")
    }
}
