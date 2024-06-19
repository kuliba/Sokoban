//
//  PaymentsSubscriberViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 31.01.2023.
//

import SwiftUI
import UIPrimitives

//MARK: - View Model

extension PaymentsSubscriberView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject  {
        
        @Published var icon: Icon
        let name: String
        let description: String?
        let style: Style
        
        private let model: Model
        
        init(icon: Icon, name: String, description: String?, style: Style, model: Model, source: PaymentsParameterRepresentable) {
            
            self.icon = icon
            self.name = name
            self.description = description
            self.style = style
            self.model = model
            super.init(source: source)
        }
        
        convenience init(with parameterSubscriber: Payments.ParameterSubscriber, model: Model) {
            
            let name = parameterSubscriber.value ?? ""
            self.init(icon: .shimmer(parameterSubscriber.icon), name: name, description: parameterSubscriber.description, style: .init(with: parameterSubscriber.style), model: model, source: parameterSubscriber)
            
            bind()
        }
        
        func bind() {
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] images in
                    
                    guard case .shimmer(let imageId) = icon else {
                        return
                    }

                    if let imageData = images[imageId] {
                        
                        guard let image = imageData.image else {
                            return
                        }
                        
                        withAnimation {
                            
                            icon = .image(image)
                        }

                    } else {
                        
                        model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [imageId]))
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Types

extension PaymentsSubscriberView.ViewModel {
    
    enum Icon {
        
        case image(Image)
        case shimmer(String)
        case placeholder
    }
    
    enum Style {
        
        case normal
        case success
        
        init(with parameter: Payments.ParameterSubscriber.Style) {
            
            switch parameter {
            case .regular: self = .normal
            case .small: self = .success
            }
        }
    }
}

//MARK: - View

struct PaymentsSubscriberView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        switch viewModel.style {
        case .normal:
            VStack(spacing: 24) {
                
                IconView(viewModel: viewModel.icon)
                    .frame(width: 64, height: 64)
            
                VStack(spacing: 8) {
                    
                    Text(viewModel.name)
                        .font(.textH3Sb18240())
                        .foregroundColor(.textSecondary)
                    
                    if let description = viewModel.description {
                        
                        Text(description)
                            .font(.textBodyMR14180())
                            .foregroundColor(.textPlaceholder)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            
        case .success:
            VStack(spacing: 10) {
                
                IconView(viewModel: viewModel.icon)
                    .frame(width: 35, height: 35)
            
                VStack(spacing: 8) {
                    
                    Text(viewModel.name)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                    
                    if let description = viewModel.description {
                        
                        Text(description)
                            .font(.textBodyMR14180())
                            .foregroundColor(.textPlaceholder)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
        }
    }
}

//MARK: - Subviews

extension PaymentsSubscriberView {
    
    struct IconView: View {
        
        let viewModel: PaymentsSubscriberView.ViewModel.Icon
        
        var body: some View {
            
            switch viewModel {
            case let .image(image):
                
                image
                    .resizable()
                    .clipShape(Circle())
                
            case .shimmer:
                
                Circle()
                    .foregroundColor(.mainColorsGrayMedium)
                    .shimmering()
                
            case .placeholder:
                
                Image.ic64Goods
                    .resizable()
                    .renderingMode(.original)
            }
        }
    }
}

//MARK: - Preview

struct PaymentsSubscriberView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSubscriberView(viewModel: .sampleShimmerNormal)
            PaymentsSubscriberView(viewModel: .samplePlaceholderNormal)
            PaymentsSubscriberView(viewModel: .samplePlaceholderSuccess)
            
            PaymentsSubscriberView(viewModel: .sampleC2BSub)
                .previewDisplayName("C2B sucscribe success")
        }
        .previewLayout(.fixed(width: 375, height: 200))
    }
}

//MARK: - Preview Content

extension PaymentsSubscriberView.ViewModel {
    
    static let sampleShimmerNormal = PaymentsSubscriberView.ViewModel(icon: .shimmer(""), name: "Цветы у дома", description: "Еженедельная доставка букета (subscriptionPurspose)", style: .normal, model: .emptyMock, source: Payments.ParameterMock())
    
    static let samplePlaceholderNormal = PaymentsSubscriberView.ViewModel(icon: .placeholder, name: "Цветы у дома", description: "Еженедельная доставка букета (subscriptionPurspose)", style: .normal, model: .emptyMock, source: Payments.ParameterMock())
    
    static let samplePlaceholderSuccess = PaymentsSubscriberView.ViewModel(icon: .placeholder, name: "Цветы у дома", description: "Еженедельная доставка букета (subscriptionPurspose)", style: .success, model: .emptyMock, source: Payments.ParameterMock())
    
    static let sampleC2BSub = PaymentsSubscriberView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Цветы у дома"), icon: "", description: nil, style: .small), model: .emptyMock)
    
    static let sampleC2B = PaymentsSubscriberView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "Цветы у дома"), icon: "", description: "Еженедельная доставка букета (subscriptionPurspose)", style: .small), model: .emptyMock)
}
