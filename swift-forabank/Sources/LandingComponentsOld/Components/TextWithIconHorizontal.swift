//
//  TextWithIconHorizontal.swift
//  
//
//  Created by Dmitry Martynov on 04.08.2023.
//

import SwiftUI
import Combine

/*
 {
         "type": "TEXTS_WITH_ICON_HORIZONTAL",
         "data": {
           "md5hash": "5da774ddfc9bc0961fac3e12cba88c55",
           "title": "Более 5 000 переводов в месяц",
           "contentCenterAndPull": false
         }
 }
 */

public struct TextWithIconHorizontalModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: TextWithIconHorizontalDataModel
    
    struct TextWithIconHorizontalDataModel: Decodable, Equatable {
        
        let md5hash: String
        let title: String
        let contentCenterAndPull: Bool
    }
    
    public func reduce(imagesDelegate: ImageProviderDelegate) -> TextWithIconHorizontalViewModel {
        
        return .init(title: data.title,
                     icon: .placeholder(data.md5hash),
                     imageProvider: imagesDelegate)
    }
}

//MARK:- ViewModel

public final class TextWithIconHorizontalViewModel: ObservableObject, Hashable {
    
    @Published var icon: ImageState
    let title: String
    let imageProvider: ImageProviderDelegate?
    let id: UUID = UUID()
    
    private var bindings = Set<AnyCancellable>()
    
    init(title: String, icon: ImageState, imageProvider: ImageProviderDelegate?)
    
    {
        self.icon = icon
        self.title = title
        self.imageProvider = imageProvider
        
        imageProvider?.resultImages
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] images in
                            
                if let imageKey = self.icon.imageKey,
                       let img = images[imageKey] {
                    withAnimation { self.icon = .image(img) }
                    }
                
        }.store(in: &bindings)
        
        guard let imageKey =  self.icon.imageKey else { return }
        self.imageProvider?.requestImages(list: .md5Hash([imageKey]))
    }
    
    public static func == (lhs: TextWithIconHorizontalViewModel,
                           rhs: TextWithIconHorizontalViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//MARK: - View
public struct TextWithIconHorizontalView: View {
    
    @ObservedObject var viewModel: TextWithIconHorizontalViewModel
    
    public init(viewModel: TextWithIconHorizontalViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color("mainColorsGrayLightest", bundle: Bundle.module))//.mainColorsGrayLightest)
            
            HStack(spacing: 8) {
                
                ZStack(alignment: .center) {
                    
                    Circle()
                        .foregroundColor(.white)//.mainColorsWhite)
                        .frame(width: 28, height: 28)
                    
                    switch viewModel.icon {
                    case .placeholder:
                        
                        Circle()
                            .foregroundColor(.gray)//.mainColorsGrayLightest)
                            .frame(width: 28, height: 28)
                            .shimmering()
                    
                    case let .image(image):
                        
                        Circle()
                            .foregroundColor(.white)//.mainColorsWhite)
                            .frame(width: 28, height: 28)
                        
                        image
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    
                }

                Text(viewModel.title)
                    .font(.body)//.textBodyMR14200())
                    .foregroundColor(.black)//.mainColorsBlack)
            
            }
            .padding(.leading)
        
        }
        .frame(height: 40)
        .padding(.horizontal)
        
    }
}

// MARK: - Preview

struct TextWithIconHorizontalView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TextWithIconHorizontalView(viewModel: .init(title: "Более 5 000 переводов в месяц",
                                                    icon: .placeholder(""),
                                                    imageProvider: nil))
    }
}
