//
//  TransfersInfoViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 28.11.2022.
//  Refactor by Dmitry Martynov on 26.12.2022
//

import SwiftUI
import Combine
import UIPrimitives

// MARK: - ViewModel

extension TransfersInfoView {
    
    class ViewModel: TransfersSectionViewModel, ObservableObject {
        
        override var type: TransfersSectionType { .info }
        
        @Published var icon: ImageStateViewModel
        let text: String
        
        private var bindings = Set<AnyCancellable>()
        private let model: Model
        
        init(_ model: Model, icon: ImageStateViewModel, text: String) {
            
            self.model = model
            self.icon = icon
            self.text = text
        }
        
        convenience init(_ model: Model, data: TransferAbroadResponseData.InfoTransferData ) {
            
            var images2Download = [String]()
            
            self.init(model,
                      icon: ImageStateViewModel.reduce(images: model.images.value,
                                                       md5hash: data.md5hash,
                                                       imagesDownloadList: &images2Download),
                      text: data.title)
            bind()
            
            if !images2Download.isEmpty {
                model.action.send(
                    ModelAction.Dictionary.DownloadImages.Request(imagesIds: images2Download))
            }
        }
        
        private func bind() {
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] images in
                 
                    guard !images.isEmpty else { return }
                    
                    if let newImg = ImageStateViewModel.updateImage(imgState: self.icon, images: images) {
                        self.icon = newImg
                    }
                    
                }.store(in: &bindings)
        }
        
    }
}

// MARK: - View

struct TransfersInfoView: View {
    
    @ObservedObject var viewModel: TransfersInfoView.ViewModel
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.mainColorsGrayLightest)
            
            HStack(spacing: 8) {
                
                ZStack(alignment: .center) {
                    
                    Circle()
                        .foregroundColor(.mainColorsWhite)
                        .frame(width: 32, height: 32)
                    
                    switch viewModel.icon {
                    case .placeholder:
                        
                        Circle()
                            .foregroundColor(.mainColorsGrayLightest)
                            .frame(width: 32, height: 32)
                            .shimmering()
                    
                    case let .image(image):
                        
                        Circle()
                            .foregroundColor(.mainColorsWhite)
                            .frame(width: 32, height: 32)
                        
                        image
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                }

                Text(viewModel.text)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsBlack)
            
            }.padding(4)
        
        }.frame(height: 40)
    }
}

// MARK: - Preview

extension TransfersInfoView.ViewModel {
    
    static let sample: TransfersInfoView.ViewModel = .init(
        .emptyMock,
        icon: .image(Image("Fire Info")),
        text: "Более 5 000 переводов в месяц")
}


struct TransfersInfoView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
        
            TransfersInfoView(viewModel: .init(.emptyMock,
                                           icon: .placeholder(""), text: "Более 5 000 переводов в месяц"))
                .previewLayout(.sizeThatFits)
                .padding(8)
            
            TransfersInfoView(viewModel: .sample)
                .previewLayout(.sizeThatFits)
                .padding(8)
        }
    }
}
