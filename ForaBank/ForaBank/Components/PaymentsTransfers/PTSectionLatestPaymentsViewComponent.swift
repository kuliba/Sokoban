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
            self.model.action.send(ModelAction.LatestPayments.List.Requested())
            super.init()
            bind()
        }
        
        init(latestPaymentsButtons: [LatestPaymentButtonVM], model: Model) {
            self.latestPaymentsButtons = latestPaymentsButtons
            self.model = model
            super.init()
        }
        
        func bind() {
            // data updates from model
            model.latestPayments
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] latestPayments in
                    
                    withAnimation {
                        
                        if !latestPayments.isEmpty {
                            
                            self.latestPaymentsButtons = Self.templateButtonData
                            //TODO: handle model -> viewModel
                            
                        } else {
                            
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
