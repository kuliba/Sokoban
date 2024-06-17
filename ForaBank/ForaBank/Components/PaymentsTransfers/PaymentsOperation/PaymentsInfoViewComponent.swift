//
//  PaymentsInfoViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI
import UIPrimitives

//MARK: - ViewModel

extension PaymentsInfoView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var icon: Icon
        let title: String
        let content: String
        
        private let model: Model

        //TODO: real placeholder required
        private static let iconPlaceholder = Image("Payments Icon Placeholder")

        init(icon: Icon, title: String, content: String, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString), model: Model = .emptyMock) {
            
            self.icon = icon
            self.title = title
            self.content = content
            self.model = model
            super.init(source: source)
        }
        
        convenience init(with parameterInfo: Payments.ParameterInfo, model: Model) {
            
            self.init(icon: Icon(with: parameterInfo.icon, model: model), title: parameterInfo.title, content: parameterInfo.parameter.value ?? "", source: parameterInfo, model: model)
            
            bind()
        }
        
        func bind() {
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [weak self] images in
                    
                    guard let self else { return }
                    
                    guard case .shimmer(let imageId) = icon else {
                        return
                    }

                    if let imageData = images[imageId] {
                        
                        guard let image = imageData.image else {
                            return
                        }
                        
                        withAnimation {
                            
                            self.icon = .remote(image)
                        }

                    } else {
                        
                        model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [imageId]))
                    }
                    
                }.store(in: &bindings)
        }
    }
}

extension PaymentsInfoView.ViewModel {
    
    enum Icon {
        
        case remote(Image)
        case local(Image)
        case shimmer(String)
        case placeholder
        
        init(with paymentsIcon: Payments.Parameter.Icon, model: Model) {
            
            switch paymentsIcon {
            case let .image(imageData):
                if let image = imageData.image {
                    
                    self = .remote(image)
                    
                } else {
                    
                    self = .placeholder
                }
                
            case let .local(name):
                self = .local(Image(name))
                
            case let .remote(imageId):
                if let imageData = model.images.value[imageId] {
                    
                    if let image = imageData.image {
                        
                        self = .remote(image)
                        
                    } else {
                        
                        self = .placeholder
                    }
                    
                } else {
                    
                    self = .shimmer(imageId)
                }
            }
        }
    }
}

//MARK: - View

struct PaymentsInfoView: View {
    
    @ObservedObject var viewModel: PaymentsInfoView.ViewModel
    var isCompact: Bool = false
    
    var body: some View {
        
        if isCompact == true {
            
            HStack {
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
                    .accessibilityIdentifier("PaymentsInfoComponentTitleCompact")
                
                Spacer()
                
                if viewModel.content != "" {
                    
                    Text(viewModel.content)
                        .font(.textBodyMR14180())
                        .lineLimit(1)
                        .foregroundColor(.textSecondary)
                        .accessibilityIdentifier("PaymentsInfoComponentTextCompact")
                }
            }
            .padding(.horizontal, 16)
            
        } else {
            
            HStack(spacing: 20) {
                
                IconView(viewModel: viewModel.icon)

                VStack(alignment: .leading, spacing: 4)  {
                    
                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                        .accessibilityIdentifier("PaymentsInfoComponentTitle")
                    
                    
                    Text(viewModel.content)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textSecondary)
                        .accessibilityIdentifier("PaymentsInfoComponentText")
                }
                
                Spacer()
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 12)
        }
    }
}

extension PaymentsInfoView {
    
    enum Style {
        
        case single
        case group
    }
}

extension PaymentsInfoView {
    
    struct IconView: View {
        
        let viewModel: PaymentsInfoView.ViewModel.Icon
        
        var body: some View {
            
            switch viewModel {
            case let .remote(image):
                image
                    .resizable()
                    .renderingMode(.original)
                    .clipShape(Circle())
                    .frame(width: 32, height: 32)
                    .accessibilityIdentifier("PaymentsInfoComponentIconRemote")
                
            case let .local(image):
                image
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
                    .accessibilityIdentifier("PaymentsInfoComponentIconLocal")
  
            case .shimmer:
                Circle()
                    .foregroundColor(.mainColorsGrayMedium)
                    .frame(width: 32, height: 32)
                    .shimmering()
                    .accessibilityIdentifier("PaymentsInfoComponentIconShimmer")
                
            case .placeholder:
                Image.ic24IconMessage
                    .renderingMode(.template)
                    .foregroundColor(.mainColorsGray)
                    .accessibilityIdentifier("PaymentsInfoComponentIconPlaceholder")
            }
        }
    }
}

//MARK: - Preview

struct PaymentsInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 32, content: previewsGroup)
                .previewDisplayName("Xcode 14+")
            
            previewsGroup()
        }
    }
    
    static func previewsGroup() -> some View {
        
        Group {

            PaymentsInfoView(viewModel: .sample, isCompact: false)
                .previewLayout(.fixed(width: 375, height: 190))
            
            PaymentsInfoView(viewModel: .sampleParameter, isCompact: false)
                .previewLayout(.fixed(width: 375, height: 100))
            
            PaymentsInfoView(viewModel: .sampleParameter, isCompact: true)
                .previewLayout(.fixed(width: 375, height: 80))
            
            PaymentsGroupView(viewModel: .sampleSingleInfo)
                .previewLayout(.fixed(width: 375, height: 140))
            
            PaymentsInfoGroupView(viewModel: .sampleInfo)
                .previewLayout(.fixed(width: 375, height: 100))
        }
    }
}

//MARK: - Preview Content

extension PaymentsInfoView.ViewModel {
    
    static let sample = PaymentsInfoView.ViewModel(icon: .remote(Image("Payments List Sample")), title: "Основание", content: "Налог на имущество физических лиц, взимаемый по ставкам, применяемым к объектам налогообложения, расположенным в границах внутригородских муниципальных образований городов федерального значения (сумма платеж...)")
    
    static let sampleParameter = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "УФК по г. Москве (ИФНС России №26 по г. Москве)"), icon: .local("ic24IconMessage"), title: "Получатель платежа"), model: .emptyMock)
    
    static let sampleGroupOne = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "123563470"), icon: .local("ic24IconMessage"), title: "Номер перевода"), model: .emptyMock)
    
    static let sampleGroupTwo = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "100 $"), icon: .local("ic24IconMessage"), title: "Сумма перевода"), model: .emptyMock)
    
    static let sampleGroupThree = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "50 ₽"), icon: .local("ic24IconMessage"), title: "Комиссия"), model: .emptyMock)
    
    static let sampleGroupFour = PaymentsInfoView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "7050 ₽"), icon: .local("ic24IconMessage"), title: "Сумма списания"), model: .emptyMock)
}

extension PaymentsGroupViewModel {
    
    static let sampleInfo = PaymentsInfoGroupViewModel(items: [PaymentsInfoView.ViewModel.sampleParameter])
}
