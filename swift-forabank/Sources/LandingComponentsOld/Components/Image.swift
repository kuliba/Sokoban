//
//  File.swift
//  
//
//  Created by Dmitry Martynov on 19.08.2023.
//

import SwiftUI
import Combine
import UIPrimitives

//TODO: 

/*
 {
    "type":"IMAGE",
    "data":{
       "imageLink":"dict\/getProductCatalogImage?image=\/products\/banners\/Header_abroad.png",
       "backgroundColor":"WHITE",
       "isPlaceholder":false
    }
 }
 */

public struct ImageModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: ImageDataModel
    
    struct ImageDataModel: Decodable, Equatable {
        
        let imageLink: String
    }
    
    public func reduce(imagesDelegate: ImageProviderDelegate) -> ImageViewModel {
        
        return .init( image: .placeholder(data.imageLink),
                      imageProvider: imagesDelegate)
    }
}

//MARK: - ViewModel
public final class ImageViewModel: ObservableObject, Hashable {
    
    @Published var image: ImageState
    let imageProvider: ImageProviderDelegate?
    let id: UUID = UUID()
    
    private var bindings = Set<AnyCancellable>()
    
    init(image: ImageState, imageProvider: ImageProviderDelegate?) {
        
        self.image = image
        self.imageProvider = imageProvider
        
        imageProvider?.resultImages
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] images in
                            
                if let imageKey = self.image.imageKey,
                       let img = images[imageKey] {
                    withAnimation { self.image = .image(img) }
                }
                
        }.store(in: &bindings)
        
        guard let imageKey =  self.image.imageKey else { return }
        self.imageProvider?.requestImages(list: .url([imageKey]))
        
    }
    
    public static func == (lhs: ImageViewModel,
                           rhs: ImageViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//MARK: - View
public struct ImageView: View {
    
    @ObservedObject var viewModel: ImageViewModel
    
    public init(viewModel: ImageViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        switch viewModel.image {
        case .placeholder:
            
            Circle()
                .foregroundColor(.gray)//.mainColorsGrayLightest)
                .frame(width: 28, height: 28)
                .shimmering()
        
        case let .image(image):
            
            
            image
                .renderingMode(.original)
                .resizable()
        }
        
    }
}


