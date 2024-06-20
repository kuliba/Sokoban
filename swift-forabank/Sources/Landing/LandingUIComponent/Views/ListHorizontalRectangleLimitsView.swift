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
    let config: Config
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: config.spacing) {
                ForEach(model.data.list, content: itemView)
            }
        }
        .padding(.horizontal, config.paddings.horizontal)
        .padding(.vertical, config.paddings.vertical)
    }
    
    private func itemView (
        item: Item
    ) -> some View {
        
        ItemView(
            item: item,
            makeIcon: model.makeIconView,
            makeLimit: model.makeLimit,
            config: config
        )
        .gesture(
            TapGesture()
                .onEnded {
                    model.itemAction(item: item)
                }
        )
    }

    typealias Item = UILanding.List.HorizontalRectangleLimits.Item
    typealias Config = UILanding.List.HorizontalRectangleLimits.Config
}

extension ListHorizontalRectangleLimitsView {
    
    struct ItemView: View {
        
        let item: UILanding.List.HorizontalRectangleLimits.Item
        let makeIcon: LandingView.MakeIconView
        let makeLimit: LandingView.MakeLimit
        
        let config: Config
        
        var body: some View {
            
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                    .cornerRadius(12)
                
                VStack(alignment: .leading) {
                    
                    HStack {
                        
                        ZStack {
                            
                            Capsule(style: .circular)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                            
                            makeIcon(item.md5hash)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        
                        Text(item.title)
                            .lineLimit(2)
                    }
                    
                    ForEach(item.limits, id: \.id) { itemView(limit: $0) }
                }
            }
            .frame(width: 180, height: 176)
        }

        private func itemView(
            limit: UILanding.List.HorizontalRectangleLimits.Item.Limit
        ) -> some View {
            
            VStack(alignment: .leading) {
                
                Text(limit.title)
                    .frame(width: 82)
                    .font(.caption)
                
                limitView(limit: makeLimit(limit.id))
            }
        }
        
        private func limitView(
            limit: LimitValues?
        ) -> some View {
            
            VStack(alignment: .leading) {
                
                Text("Осталось сегодня")
                    .font(.caption2)
                
                HStack {
                    Text(value(limit: limit?.currentValue))
                        .font(.subheadline)
                    Text(limit?.currency ?? "")
                        .font(.subheadline)

                    circleLimit(limit: limit)
                        .frame(width: 20, height: 20)
                    
                }
                Text("Осталось в этом месяце")
                    .font(.caption2)
                
                HStack {
                    Text(value(limit: limit?.value))
                        .font(.subheadline)
                    Text(limit?.currency ?? "")
                        .font(.subheadline)

                    circleLimit(limit: limit)
                        .frame(width: 20, height: 20)
                    
                }
            }
        }
        
        private func circleLimit(limit: LimitValues?) -> some View {
            
            ZStack {
                Arc(startAngle: .degrees(-90), endAngle: .degrees(15), clockwise: true)
                    .stroke(.blue, lineWidth: 4)
                    .frame(width: 12, height: 12)
                Arc(startAngle: .degrees(0), endAngle: .degrees(-75), clockwise: true)
                    .stroke(.red, lineWidth: 2)
                    .frame(width: 12, height: 12)
            }
            .frame(width: 20, height: 20)
        }
        
        struct Arc: Shape {
            var startAngle: Angle
            var endAngle: Angle
            var clockwise: Bool
            
            func path(in rect: CGRect) -> Path {
                var path = Path()
                path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
                
                return path
            }
        }
        
        // возможно стоит перенести в основной таргет
        
        private func value(limit: Decimal?) -> String {
            
            if let limit {
                return "\(limit)"
            }
            else { return "Не установлен" }
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
                            limitType: "Debit",
                            md5hash: "1", title: "title",
                            limits: [
                                .init(
                                    id: "1",
                                    title: "Платежи и переводы",
                                    colorHEX: "#11111")]),
                        .init(
                            action: .init(type: "action"),
                            limitType: "Credit",
                            md5hash: "md5Hash", title: "title",
                            limits: [
                                .init(
                                    id: "2",
                                    title: "Снятие наличных",
                                    colorHEX: "#11111")])
                    ]),
        action: { _ in }
        ,
        makeIconView: {
            if $0 == "1" {
                .init(
                    image: .flag,
                    publisher: Just(.percent).eraseToAnyPublisher()
                ) } else {
                    .init(
                        image: .percent,
                        publisher: Just(.flag).eraseToAnyPublisher()
                        
                    )}
        },
        makeLimit: {
            
            if $0 == "1" {
                return .init(currency: "₽", currentValue: 10, name: "1", value: 200)
            } else {
                
                return .init(currency: "$", currentValue: 200, name: "2", value: 400)
            }
        })
}
