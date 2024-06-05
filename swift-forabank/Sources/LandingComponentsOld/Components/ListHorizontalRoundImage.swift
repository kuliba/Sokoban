//
//  ListHorizontalRoundImage.swift
//  
//
//  Created by Dmitry Martynov on 19.07.2023.
//

import SwiftUI
import Combine

//MARK: - Model
/*
 {
   "type":"LIST_HORIZONTAL_ROUND_IMAGE",
   "data":{
      "title":"Популярные направления",
      "list":[
         {
            "md5hash":"6046e5eaff596a41ce9845cca3b0a887",
            "title":"Армения",
            "subInfo":"1%",
            "details":{
               "detailsGroupId":"forCountriesList",
               "detailViewId":"Armeniya"
            }
         }
      ]
   }
}

*/

public struct ListHorizontalRoundImageModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: ListHorizontalRoundImageData
    
    struct ListHorizontalRoundImageData: Decodable, Equatable {
        let title: String?
        let list: [ListHorizontalRoundImageDataList]
    }
    
    struct ListHorizontalRoundImageDataList: Decodable, Equatable {
        let md5hash: String
        let title: String
        let subInfo: String?
        let details: ListHorizontalRoundImageDataListDetails?
    }
    
    struct ListHorizontalRoundImageDataListDetails: Decodable, Equatable {
        let detailsGroupId: String
        let detailViewId: String
    }
    
    public func reduce(imagesDelegate: ImageProviderDelegate) -> ListHorizontalRoundImageViewModel {
        
        let items = data.list.map {
            
            ListHorizontalRoundImageViewModel.ItemViewModel
                .init(title: $0.title,
                      rateTitle: $0.subInfo,
                      icon: .placeholder($0.md5hash))
        }
        
        return .init(title: data.title,
                     items: items,
                     imageProvider: imagesDelegate)
    }
}

// MARK: - ViewModel

public final class ListHorizontalRoundImageViewModel: ObservableObject {
    
    @Published var items: [ItemViewModel]
    let title: String?
    let imageProvider: ImageProviderDelegate?
    let id: UUID = UUID()
    
    
    private var bindings = Set<AnyCancellable>()
    
    init(title: String?,
         items: [ItemViewModel],
         imageProvider: ImageProviderDelegate?) {
        
        self.items = items
        self.title = title
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
        self.imageProvider?.requestImages(list: .md5Hash(imageKeys))
        
    }
    
    
}
    
extension ListHorizontalRoundImageViewModel: Hashable {

    class ItemViewModel: ObservableObject, Identifiable {

        var id: String { title }
        let title: String
        let rateTitle: String?
        @Published var icon: ImageState

        init(title: String, rateTitle: String?, icon: ImageState) {
    
            self.title = title
            self.rateTitle = rateTitle
            self.icon = icon
        }

    }
    
    public static func == (lhs: ListHorizontalRoundImageViewModel, rhs: ListHorizontalRoundImageViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - View

public struct ListHorizontalRoundImageView: View {
    
    @ObservedObject var viewModel: ListHorizontalRoundImageViewModel
    
    public init(viewModel: ListHorizontalRoundImageViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color("mainColorsGrayLightest", bundle: Bundle.module))
            
            VStack(alignment: .leading, spacing: 16) {

                if let title = viewModel.title {
                    
                    HStack {
                        
                        Text(title)
                            .font(.body) //.textH3SB18240())
                            .foregroundColor(.black) //.mainColorsBlack)
                        
                        Spacer()
                        
                    }.padding(.horizontal)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {

                    HStack {

                        ForEach(viewModel.items) { item in
                            ItemView(viewModel: item)
                        }

                    }.padding(.horizontal, 8)
                }
            }
        
        }
        .frame(height: 148)
        .padding(.horizontal)
    }
}

extension ListHorizontalRoundImageView {
    
    struct ItemView: View {
        
        @ObservedObject var viewModel: ListHorizontalRoundImageViewModel.ItemViewModel
        
        var body: some View {
            
            Button(action: {} ) { //viewModel.onAction) {
                
                ZStack {
                                 
                    VStack(spacing: 8) {
                         
                        switch viewModel.icon {
                        case let .image(image):
                            
                            image
                                .resizable()
                                .cornerRadius(28)
                                .frame(width: 56, height: 56)
                        
                        case .placeholder:
                            
                            Circle()
                                .foregroundColor(.gray)//.mainColorsGrayMedium.opacity(0.4))
                                .frame(width: 56, height: 56)
                                .shimmering()
                        }
                        
                        Text(viewModel.title)
                            .font(.caption)//.textBodySR12160())
                            .foregroundColor(.black)//.mainColorsBlack)
                    }
                    
                    if let rateTitle = viewModel.rateTitle {
                        
                        HStack {
                            
                            Spacer()
                            
                            VStack {
                                
                                HStack(alignment: .center) {
                                    
                                    Text(rateTitle)
                                        .font(.body)//.textBodyXSSB11140())
                                        .foregroundColor(.gray)//.mainColorsGray)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                }
                                .background(Color.white)//mainColorsWhite)
                                .cornerRadius(12)
                                
                                Spacer()
                            }
                            
                        }.frame(width: 72)
                    }
                
                }.fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - PreviewContent

extension ListHorizontalRoundImageViewModel {
    
    static var sampleItems: [ItemViewModel] = [
        .init(title: "Армения",
              rateTitle: "1%",
              icon: .placeholder("md5hash")),
        .init(title: "Беларусь",
              rateTitle: nil,
              icon: .image(Image("BelarusFlag", bundle: Bundle.module))),
        .init(title: "Грузия",
              rateTitle: "1,5%",
              icon: .image(Image("GeorgiaFlag", bundle: Bundle.module)))]
}

// MARK: - Preview

struct ListHorizontalRoundImageView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ListHorizontalRoundImageView(viewModel: .init(
            title: "Популярные направления",
            items: ListHorizontalRoundImageViewModel.sampleItems,
            imageProvider: nil))
        .padding()
    }
}

