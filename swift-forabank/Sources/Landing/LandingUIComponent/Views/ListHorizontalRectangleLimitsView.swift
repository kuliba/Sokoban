//
//  ListHorizontalRectangleLimitsView.swift
//
//
//  Created by Andryusina Nataly on 10.06.2024.
//

import SwiftUI
import Combine
import UIPrimitives

struct ListHorizontalRectangleLimitsView: View {
    
    @ObservedObject var model: ViewModel
    let config: UILanding.List.HorizontalRectangleLimits.Config
        
    var body: some View {
            
            ScrollView(.horizontal, showsIndicators: false) {
               
                HStack(spacing: config.spacing) {
                    ForEach(model.data.list, content: itemView)
                }
            }
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, config.paddings.vertical)
    }
    
    private func itemView (item: UILanding.List.HorizontalRectangleLimits.Item) -> some View {
        
        ItemView(
            item: item,
            config: config
        )
    }
}

extension ListHorizontalRectangleLimitsView {
    
    struct ItemView: View {
        
        let item: UILanding.List.HorizontalRectangleLimits.Item
        let config: UILanding.List.HorizontalRectangleLimits.Config
        
        var body: some View {
            // TODO: - add view
            Text("LimitView")
        }
    }
}

struct ListHorizontalRectangleLimitsView_Previews: PreviewProvider {
    static var previews: some View {
        
        ListHorizontalRectangleLimitsView(
            model: defaultValue,
            config: .default)
        
    }
    static let defaultValue: ListHorizontalRectangleLimitsView.ViewModel = .init(
        data:
            .init(
                list: [
                    .init(
                        action: .init(type: "action"),
                        limitType: "limitType",
                        md5hash: "md5Hash", title: "title",
                        limits: [
                            .init(
                                id: "1",
                                title: "limit title",
                                colorHEX: "#11111")])])
        ,
        makeIconView: { _ in .init(
            image: .flag,
            publisher: Just(.percent).eraseToAnyPublisher()
        )})
}
