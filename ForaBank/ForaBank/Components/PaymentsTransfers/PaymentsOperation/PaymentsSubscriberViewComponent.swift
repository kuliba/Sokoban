//
//  PaymentsSubscriberViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 31.01.2023.
//

import SwiftUI
import Shimmer

//MARK: - View Model

extension PaymentsSubscriberView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject  {
        
        @Published var icon: Icon
        @Published var name: String
        @Published var description: String
        
        private let model: Model
        
        init(icon: Icon, name: String, description: String, model: Model, source: PaymentsParameterRepresentable) {
            
            self.icon = icon
            self.name = name
            self.description = description
            self.model = model
            super.init(source: source)
        }
        
        convenience init(with parameterSubscriber: Payments.ParameterSubscriber, model: Model) {
            
            let name = parameterSubscriber.value ?? ""
            self.init(icon: .shimmer(parameterSubscriber.icon), name: name, description: parameterSubscriber.description, model: model, source: parameterSubscriber)
            
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
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ModelAction.Dictionary.DownloadImages.Response:
                        
                        guard case .shimmer(let imageId) = icon else {
                            return
                        }
                        
                        switch payload.result {
                        case .success(let images):
                            
                            if let imageData = images.first(where: { $0.id == imageId })?.imageData {
                                
                                if let image = imageData.image {
                                    
                                    withAnimation {
                                        
                                        icon = .image(image)
                                    }
                                } else {
                                    
                                    withAnimation {
                                        icon = .placeholder
                                    }
                                }
                                
                            } else {
                                
                                withAnimation {
                                    icon = .placeholder
                                }
                            }
                            
                        case .failure:
                            withAnimation {
                                icon = .placeholder
                            }
                        }
                        
                    default:
                        break
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
}

//MARK: - View

struct PaymentsSubscriberView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            IconView(viewModel: viewModel.icon)
            
            VStack(spacing: 8) {
                
                Text(viewModel.name)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.description)
                    .font(.textBodyMR14180())
                    .foregroundColor(.textPlaceholder)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
        }.padding(.vertical, 20)
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
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                
            case .shimmer:
                
                Circle()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.mainColorsGrayMedium)
                    .shimmering()
                
            case .placeholder:
                
                Image.ic64Goods
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 64, height: 64)
            }
        }
    }
}

struct PaymentsSubscriberView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
        PaymentsSubscriberView(viewModel: .init(icon: .shimmer(""), name: "Цветы у дома", description: "Еженедельная доставка букета (subscriptionPurspose)", model: .emptyMock, source: Payments.ParameterMock()))
            .previewLayout(.fixed(width: 375, height: 200))
            PaymentsSubscriberView(viewModel: .init(icon: .placeholder, name: "Цветы у дома", description: "Еженедельная доставка букета (subscriptionPurspose)", model: .emptyMock, source: Payments.ParameterMock()))
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}
