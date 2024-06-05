//
//  ListHorizontalRectangleImage.swift
//  
//
//  Created by Dmitry Martynov on 07.08.2023.
//

//"LIST_HORIZONTAL_RECTANGLE_IMAGE"

import SwiftUI
import Combine
import UIPrimitives

//MARK: - Model
/*
 {
         "type": "LIST_HORIZONTAL_RECTANGLE_IMAGE",
         "data": {
           "list": [
             {
               "imageLink": "dict/getProductCatalogImage?image=/products/banners/Product_abroad_1.png",
               "link": "https://www.forabank.ru/landings/mig/",
               "details": {
                 "detailsGroupId": "bannersLanding",
                 "detailViewId": "oneThousandForTransfer"
               }
             }
           ]
        }
*/

public struct ListHorizontalRectangleImageModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: ListHorizontalRectangleImageData
    
    struct ListHorizontalRectangleImageData: Decodable, Equatable {
        let list: [ListHorizontalRectangleImageDataList]
    }
    
    struct ListHorizontalRectangleImageDataList: Decodable, Equatable {
        let imageLink: String
        let link: String
        let details: ListHorizontalRectangleImageDataListDetails?
    }
    
    struct ListHorizontalRectangleImageDataListDetails: Decodable, Equatable {
        let detailsGroupId: String
        let detailViewId: String
    }
    
    public func reduce(imagesDelegate: ImageProviderDelegate) -> ListHorizontalRectangleImageViewModel {
        
        let items = data.list.map {
            
            ListHorizontalRectangleImageViewModel.ItemViewModel
                .init(icon: .placeholder($0.imageLink))
        }
        
        return .init(items: items,
                     imageProvider: imagesDelegate)
    }
}

// MARK: - ViewModel

public final class ListHorizontalRectangleImageViewModel: ObservableObject {
    
    @Published var items: [ItemViewModel]
    let imageProvider: ImageProviderDelegate?
    let id: UUID = UUID()
    
    private var bindings = Set<AnyCancellable>()
    
    init(items: [ItemViewModel],
         imageProvider: ImageProviderDelegate?) {
        
        self.items = items
        self.imageProvider = imageProvider
        
        imageProvider?.resultImages
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] images in
            
                self.items.forEach { item in
                            
                    if let imageKey = item.icon.imageKey,
                       let img = images[imageKey] {
                        withAnimation { item.icon = .image(img) }
                    }
                }
        }.store(in: &bindings)
        
        let imageKeys = self.items.compactMap { $0.icon.imageKey }
        self.imageProvider?.requestImages(list: .url(imageKeys))
        
    }
    
}
    
extension ListHorizontalRectangleImageViewModel: Hashable {

    class ItemViewModel: ObservableObject, Identifiable {

        let id = UUID()
        @Published var icon: ImageState
        
        lazy var action: () -> Void = { [weak self] in
            
            guard let self = self else { return }
            //self.action.send(TransfersItemAction.Item.Tap(countryCode: self.countryCode))
        }

        init(icon: ImageState) {
    
            self.icon = icon
        }

    }
    
    public static func == (lhs: ListHorizontalRectangleImageViewModel, rhs: ListHorizontalRectangleImageViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - View

public struct ListHorizontalRectangleImageView: View {
    
    public init(viewModel: ListHorizontalRectangleImageViewModel) {
        self.viewModel = viewModel
    }
    
    @ObservedObject var viewModel: ListHorizontalRectangleImageViewModel
    
    public var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 8) {
                
                ForEach(viewModel.items) { itemViewModel in
                    
                    ItemView(viewModel: itemViewModel)
                }
            }
        }.padding(.horizontal)
    }
}

extension ListHorizontalRectangleImageView {
    
    struct ItemView: View {
            
        @ObservedObject var viewModel: ListHorizontalRectangleImageViewModel.ItemViewModel
            
        var body: some View {
                
                switch viewModel.icon {
                case .placeholder:
                    
                    Color.gray //mainColorsGrayLightest
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(width: 288, height: 124)
                        .shimmering()
                        
                    
                case .image(let image):
                    
                    Button(action: viewModel.action) {
                            
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 288, height: 124)
                                .cornerRadius(12)
                            
                        }
                        //.buttonStyle(PushButtonStyle())
                }
        }
    }
    
}


// MARK: - PreviewContent

extension ListHorizontalRectangleImageViewModel {
    
    static var sampleItems: [ItemViewModel] = [
        .init(icon: .image(Image("Banner", bundle: Bundle.module))),
        .init(icon: .placeholder("urlString"))
    ]
}

// MARK: - Preview

struct ListHorizontalRectangleImageView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ListHorizontalRectangleImageView(viewModel: .init(
            
            items: ListHorizontalRectangleImageViewModel.sampleItems,
            imageProvider: nil))
    }
}
