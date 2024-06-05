//
//  ListVerticalRoundImage.swift
//  
//
//  Created by Dmitry Martynov on 08.08.2023.
//

import SwiftUI
import Combine
import UIPrimitives

/*
{
        "type": "LIST_VERTICAL_ROUND_IMAGE",
        "data": {
          "title": "Список стран",
          "displayedCount": 5,
          "dropButtonOpenTitle": "Смотреть все страны",
          "dropButtonCloseTitle": "Скрыть все страны",
          "list": [
            {
              "md5hash": "873ae820e558f131084e80df69d6efad",
              "title": "Абхазия",
              "subTitle": "Абхазия",
              "details": {
                "detailsGroupId": "forCountriesList",
                "detailViewId": "Abhaziya"
              }
            }
          ]
        }
 }
 
 {
         "type": "LIST_VERTICAL_ROUND_IMAGE",
         "data": {
           "title": "Преимущества",
           "list": [
             {
               "md5hash": "c1922354c30751af8867aa0e13d07fa1",
               "title": "Выгодно",
               "subTitle": "Низкие проценты"
             },
             {
               "md5hash": "d66499e075262b782331c20b5fbe7299",
               "title": "Мгновенно",
               "subTitle": "На карту получателя"
             },
             {
               "md5hash": "d5cbcabf90f3406a0bb7779579e2a2cb",
               "title": "Круглосуточно",
               "subTitle": "В мобильном приложении"
             },
             {
               "md5hash": "d072abacb3d2ed748777db9dd39d29ec",
               "title": "Удобно",
               "subTitle": "По номеру телефона"
             }
           ]
         }
       }
*/

public struct ListVerticalRoundImageModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: ListVerticalRoundImageData
    
    struct ListVerticalRoundImageData: Decodable, Equatable {
        let title: String?
        let displayedCount: Int?
        let dropButtonOpenTitle: String?
        let dropButtonCloseTitle: String?
        let list: [ListVerticalRoundImageDataList]
    }
    
    struct ListVerticalRoundImageDataList: Decodable, Equatable {
        let md5hash: String
        let title: String
        let subTitle: String?
        let details: ListVerticalRoundImageDataListDetails?
    }
    
    struct ListVerticalRoundImageDataListDetails: Decodable, Equatable {
        let detailsGroupId: String
        let detailViewId: String
    }
    
    public func reduce(imagesDelegate: ImageProviderDelegate) -> ListVerticalRoundImageViewModel {
        
        let items = data.list.map {
            
            ListVerticalRoundImageViewModel.ItemViewModel
                .init(title: $0.title,
                      subTitle: $0.subTitle,
                      icon: .placeholder($0.md5hash))
        }
        var buttonTitles: (full: String, short: String)?
        if let shortTitle = data.dropButtonOpenTitle,
           let fullTitle = data.dropButtonCloseTitle {
            
            buttonTitles = (fullTitle, shortTitle)
        }
        
        return .init(title: data.title,
                     fullItems: items,
                     displayItemsCount: data.displayedCount ?? 0,
                     buttonTitles: buttonTitles,
                     imageProvider: imagesDelegate)
    }
}

// MARK: - ViewModel

public final class ListVerticalRoundImageViewModel: ObservableObject {
    
    @Published var items: [ItemViewModel]
    let fullItems: [ItemViewModel]
    let displayItemsCount: Int
    let buttonTitles: (full: String, short: String)?
    
    let title: String?
    let imageProvider: ImageProviderDelegate?
    let id: UUID = UUID()
    
    @Published var isCollapsed: Bool
    
    var button: ButtonViewModel? = nil
    
    private var bindings = Set<AnyCancellable>()
    
    init(title: String?,
         fullItems: [ItemViewModel],
         displayItemsCount: Int,
         buttonTitles: (full: String, short: String)?,
         imageProvider: ImageProviderDelegate?) {
        
        self.items = fullItems
        self.title = title
        self.imageProvider = imageProvider
        self.fullItems = fullItems
        self.displayItemsCount = displayItemsCount
        self.buttonTitles = buttonTitles
        self.isCollapsed = displayItemsCount != 0
        
        if isCollapsed {
         
            self.button = .init { [weak self] in
                self?.isCollapsed.toggle()
            }
        }
        
        let imageKeys = self.fullItems.compactMap { $0.icon.imageKey }
        self.imageProvider?.requestImages(list: .md5Hash(imageKeys))
        
        bind()
    }
    
    private func bind() {
        
        imageProvider?.resultImages
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] images in
            
                self.fullItems.forEach { item in
                            
                    if let imageKey = item.icon.imageKey,
                       let img = images[imageKey] {
                        withAnimation { item.icon = .image(img) }
                    }
                }
        }.store(in: &bindings)
        
        $isCollapsed
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isCollapsed in
                
                withAnimation {
                    if isCollapsed {
                        
                        self.items = fullItems.dropLast(fullItems.count - displayItemsCount)
                        self.button?.title = buttonTitles?.short ?? ""
                        
                    } else {
                        self.items = fullItems
                        self.button?.title = buttonTitles?.full ?? ""
                    }
                }
                
            }.store(in: &bindings)
        
    }
}
    
extension ListVerticalRoundImageViewModel: Hashable {

    class ItemViewModel: ObservableObject, Identifiable {

        var id: String { title }
        let title: String
        let subTitle: String?
        @Published var icon: ImageState

        init(title: String, subTitle: String?, icon: ImageState) {
    
            self.title = title
            self.subTitle = subTitle
            self.icon = icon
        }
    }
    
    class ButtonViewModel: ObservableObject {

        @Published var title: String

        let icon: Image
        let action: () -> Void
        
        init(title: String, icon: Image, action: @escaping () -> Void) {
            
            self.title = title
            self.icon = icon
            self.action = action
        }
        
        convenience init(_ action: @escaping () -> Void) {
            
            self.init(
                title: "",
                icon: Image("ic24MoreHorizontal", bundle: Bundle.module),
                action: action
            )
        }
    }
    
    public static func == (lhs: ListVerticalRoundImageViewModel, rhs: ListVerticalRoundImageViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - View

public struct ListVerticalRoundImageView: View {
    
    @ObservedObject var viewModel: ListVerticalRoundImageViewModel
    
    public init(viewModel: ListVerticalRoundImageViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
            
        ZStack(alignment: .leading) {
                
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color("mainColorsGrayLightest", bundle: Bundle.module)) //.mainColorsGrayLightest)
                
            VStack(alignment: .leading, spacing: 24) {

                if let mainTitle = viewModel.title {
                        
                    Text(mainTitle)
                        //.font(.textH3SB18240())
                        //.foregroundColor(.mainColorsBlack)
                }
                    
                ForEach(viewModel.items) { item in
                        ItemView(viewModel: item)
                }
                
                if let buttonModel = viewModel.button {
                    ButtonView(viewModel: buttonModel)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }.padding(.horizontal)
    }
}


extension ListVerticalRoundImageView {
    
    struct ItemView: View {
        
        @ObservedObject var viewModel: ListVerticalRoundImageViewModel.ItemViewModel
        
        var body: some View {
            
            HStack(spacing: 20) {
                
                switch viewModel.icon {
                case let .image(image):
                    
                    image
                        .resizable()
                        .cornerRadius(28)
                        .frame(width: 40, height: 40)
                
                case .placeholder:
                        
                        Circle()
                            .foregroundColor(.gray) //.mainColorsGrayMedium.opacity(0.4))
                            .frame(width: 40, height: 40)
                            .shimmering()
                }

                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.title)
                        //.font(.textH4M16240())
                        //.foregroundColor(.mainColorsBlack)
                    
                    if let subTitle = viewModel.subTitle {
                        
                        Text(subTitle)
                        //.font(.textBodySR12160())
                        //.foregroundColor(.mainColorsGray)
                    }
                }
                
            }
        }
    }
    
    struct ButtonView: View {
        
        @ObservedObject var viewModel: ListVerticalRoundImageViewModel.ButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                HStack(spacing: 20) {
                    
                    ZStack(alignment: .center) {
                        
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)//.mainColorsWhite)
                        
                        viewModel.icon
                            .renderingMode(.original)
                    }
                    
                    Text(viewModel.title)
                        //.font(.textH4M16240())
                        .foregroundColor(.black)//.mainColorsBlack)
                }
            }
        }
    }
}

// MARK: - PreviewContent

extension ListVerticalRoundImageViewModel {
    
    static var sampleItems: [ItemViewModel] = [
        .init(title: "Армения",
              subTitle: "1%",
              icon: .placeholder("md5hash")),
        .init(title: "Беларусь",
              subTitle: nil,
              icon: .image(Image("BelarusFlag", bundle: Bundle.module))),
        .init(title: "Грузия",
              subTitle: "1,5%",
              icon: .image(Image("GeorgiaFlag", bundle: Bundle.module)))]
}

// MARK: - Preview

struct ListVerticalRoundImageView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ListVerticalRoundImageView(viewModel: .init(
            title: "Популярные направления",
            fullItems: ListVerticalRoundImageViewModel.sampleItems,
            displayItemsCount: 2,
            buttonTitles: (full: "Скрыть все страны", short: "Смотреть все страны"),
            imageProvider: nil))
        .padding()
    }
}
