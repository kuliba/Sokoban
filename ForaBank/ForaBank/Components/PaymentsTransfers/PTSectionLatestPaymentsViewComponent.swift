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
        private let contactsAgent: ContactsAgent
        private var contactsAgentStatus: ContactsAgentStatus
        
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
            self.contactsAgent = ContactsAgent()
            self.contactsAgentStatus = .disabled
            super.init()
            bind()
        }
        
        init(latestPaymentsButtons: [LatestPaymentButtonVM], model: Model) {
            self.latestPaymentsButtons = latestPaymentsButtons
            self.model = model
            self.contactsAgent = ContactsAgent()
            self.contactsAgentStatus = .disabled //TODO: Mock
            super.init()
        }
        
        func bind() {
            
            contactsAgent.status
                .assign(to: \.contactsAgentStatus, on: self)
                .store(in: &bindings)
            
            // data updates from model
            model.latestPayments
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] latestPayments in
                    
                    withAnimation {
                        
                        if !latestPayments.isEmpty {
                            
                            self.contactsAgent.requestPermission()
                            self.latestPaymentsButtons = Self.templateButtonData
                            
                            for item in latestPayments {
                                
                                var image: LatestPaymentButtonVM.ImageType = .text(item.type.rawValue)
                                var topIcon: Image?
                                var text = ""
                                
                                switch item.type {
                                
                                case .phone:
                                    guard let paymentData = item as? PaymentGeneralData else { return }
                                    
                                    text = paymentData.phoneNumber
                                    image = .icon(Image("ic24Smartphone"), .iconGray)
            
                                    if let bank = model.dictionaryBank(for: paymentData.bankId) {
                                        topIcon = bank.svgImage.image
                                    }
                                    
                                    var contact: AdressBookContact?
                                    if case .available = self.contactsAgentStatus {
                                        contact = self.contactsAgent.fetchContact(by: paymentData.phoneNumber)
                                        
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
                                    guard let paymentData = item as? PaymentCountryData else { return }
                                    
                                    text = paymentData.shortName
                                    image = .icon(Image("ic24Smartphone"), .iconGray)
            
                                    if let phone = paymentData.phoneNumber {
                                            text = phone
                                    }
                                    
                                    if let country = model.dictionaryCountry(for: paymentData.countryCode) {
                                        topIcon = country.svgImage?.image
                                    }
                                    
                                case .service:
                                    guard let paymentData = item as? PaymentServiceData else { return }
                                    
                                    text = String(paymentData.puref)
                                    image = .image(Image("ic24Smartphone"))
                                    
                                    if let oper = model.dictionaryAnywayOperator(for: paymentData.puref) {
                                    
                                        text = oper.name
                                        if let logo = oper.logotypeList.first?.svgImage?.image {
                                            image = .image(logo)
                                        }
                                    }
                                    
                                default:
                                    image = .text(item.type.rawValue)
                                    text = item.type.rawValue
                                }
                                
                                let button = LatestPaymentButtonVM(image: image,
                                                                   topIcon: topIcon,
                                                                   description: text,
                                                                   action: {})
                                self.latestPaymentsButtons.append(button)
                                
                            } //for
                            
                        } else {
                            print("mdy LPVM Empty")
                            self.latestPaymentsButtons = Self.templateButtonData
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

//MARK: - Preview

struct PTSectionLatestPaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PTSectionLatestPaymentsView(viewModel: .sample)
            .previewLayout(.fixed(width: 350, height: 150))
            .previewDisplayName("Section LatestPayments")
    }
}
