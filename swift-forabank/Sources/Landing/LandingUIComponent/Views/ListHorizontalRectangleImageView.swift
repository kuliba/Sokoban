//
//  ListHorizontalRectangleImageView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI
import Combine
import UIPrimitives

struct ListHorizontalRectangleImageView: View {
    
    @ObservedObject var model: ViewModel
    let config: UILanding.List.HorizontalRectangleImage.Config
        
    var body: some View {
            
            ScrollView(.horizontal, showsIndicators: false) {
               
                HStack(spacing: config.spacing) {
                    ForEach(model.data.list, id: \.imageLink, content: itemView)
                }
            }
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, config.paddings.vertical)
    }
    
    private func itemView (item: UILanding.List.HorizontalRectangleImage.Item) -> some View {
        
        ItemView(
            item: item,
            config: config,
            image: model.image(byImageLink: item.imageLink),
            action: { model.itemAction(item: item) }
        )
    }
}

extension ListHorizontalRectangleImageView {
    
    struct ItemView: View {
        
        let item: UILanding.List.HorizontalRectangleImage.Item
        let config: UILanding.List.HorizontalRectangleImage.Config
        let image: Image?
        let action: () -> Void

        var body: some View {
            
            Button(action: action) {
                
                VStack(spacing: config.spacing) {
                    
                    switch image {
                    case .none:
                        Color.grayLightest
                            .cornerRadius(config.cornerRadius)
                            .frame(width: config.size.width)
                            .frame(maxHeight: config.size.height)
                            .shimmering()
                            .accessibilityIdentifier("HorizontalRectangleImageNone")
                        
                    case let .some(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: config.size.width)
                            .frame(maxHeight: config.size.height)
                            .cornerRadius(config.cornerRadius)
                            .accessibilityIdentifier("HorizontalRectangleImage")
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .disabled(item.detail == nil && item.link.isEmpty)
        }
    }
}

extension UILanding.List.HorizontalRectangleImage.Item {
    
    var detailDestination: DetailDestination? {
        
        detail.map {
            .init(
                groupID: .init($0.groupId),
                viewID: .init($0.viewId)
            )
        }
    }
}

struct ListHorizontalRectangleImageView_Previews: PreviewProvider {
    static var previews: some View {
        
        ListHorizontalRectangleImageView(
            model: defaultValue,
            config: .default)
        
    }
    static let defaultValue: ListHorizontalRectangleImageView.ViewModel = .init(
        data: .init(
        list: [
            .init(imageLink: "111", link: "2222", detail: .none),
            .init(imageLink: "122", link: "2222", detail: .none)
        ]), 
        images: .defaultValue,
        action: { _ in },
        selectDetail: { _ in }, 
        canOpenDetail: { _ in true }
    )
}
