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
     
        @Published
        var latestPaymentsButtons: [LatestPaymentButtonVM]
        
        override var type: PaymentsTransfersSectionType { .latestPayments }
        private let model: Model
        
        private var bindings = Set<AnyCancellable>()
        
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
        
        init(model: Model) {
            self.latestPaymentsButtons = Self.templateButtonData
            self.model = model
            super.init()
            bind()
        }
        
        init(latestPaymentsButtons: [LatestPaymentButtonVM], model: Model) {
            self.latestPaymentsButtons = latestPaymentsButtons
            self.model = model
            super.init()
        }
        
        func bind() {
            
            model.latestPayments
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] latestPayments in
                    
                    withAnimation {
                        
                        self.latestPaymentsButtons = Self.templateButtonData
                        
                        guard !latestPayments.isEmpty else { return }
                        
                        self.model.action.send(ModelAction.Contacts.PermissionStatus.Request())
                        latestPayments.forEach {
                            self.latestPaymentsButtons.append(.init(data: $0, model: self.model))
                        }
                    }
        
                }.store(in: &bindings)
        }
        
        static let templateButtonData: [LatestPaymentButtonVM] = {
            [
                .init(image: .icon(Image("ic24Star"), .iconBlack),
                    topIcon: nil,
                    description: "Шаблоны и автоплатежи",
                    action: {})
            ]
        }()
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
        case .country: return .init(image: .icon(Image("ic24Smartphone"), .iconGray),
                                    topIcon: nil, description: "За рубеж", action: {})
        
        case .phone: return .init(image: .icon(Image("ic24Smartphone"), .iconGray),
                                  topIcon: nil, description: "По телефону", action: {})
        
        case .service, .mobile, .transport, .internet, .taxAndStateService:
                     return .init(image: .icon(Image("ic24Smartphone"), .iconGray),
                                  topIcon: nil, description: "Услуги", action: {})
        }
    }
}

//MARK: LatestPaymentButtonVM init

extension PTSectionLatestPaymentsView.ViewModel.LatestPaymentButtonVM {

    init(data: LatestPaymentData, model: Model) {
        
        var image = data.type.defaultButton.image
        var topIcon = data.type.defaultButton.topIcon
        var text = data.type.defaultButton.description
        var action = data.type.defaultButton.action
        
        switch data.type {
        case .phone:
            guard let paymentData = data as? PaymentGeneralData else { break }
            
            text = paymentData.phoneNumber
            image = .icon(Image("ic24Smartphone"), .iconGray)
            
            if let bank = model.dictionaryBank(for: paymentData.bankId) {
                topIcon = bank.svgImage.image
            }
            
            var contact: AdressBookContact?
            if case .available = model.contactsAgent.status.value {
                contact = model.contactsAgent.fetchContact(by: paymentData.phoneNumber)
                
                if let contact = contact {
                    if let fullName = contact.fullName {
                        text = fullName
                    }
                    
                    if let avatar = contact.avatar {
                        image = .image(Image(data: avatar.data)!)
                    } else {
                        if let initials = contact.initials {
                            image = .text(initials)
                        }
                    }
                }
            }
            
        case .country:
            guard let paymentData = data as? PaymentCountryData else { break }
            
            text = paymentData.shortName
            image = .icon(Image("ic24Smartphone"), .iconGray)
            
            if let phone = paymentData.phoneNumber {
                text = phone
            }
            
            if let country = model.dictionaryCountry(for: paymentData.countryCode) {
                topIcon = country.svgImage?.image
            }
            
        case .service, .taxAndStateService, .transport, .internet, .mobile:
            guard let paymentData = data as? PaymentServiceData else { break }
            
            text = String(paymentData.puref)
            image = .image(Image("ic24Smartphone"))
            
            if let oper = model.dictionaryAnywayOperator(for: paymentData.puref) {
                
                text = oper.name
                if let logo = oper.logotypeList.first?.svgImage?.image {
                    image = .image(logo)
                }
            }
            
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
