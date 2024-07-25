//
//  BlockHorizontalRectangularView.swift
//
//
//  Created by Andryusina Nataly on 11.06.2024.
//

import SwiftUI
import Combine
import UIPrimitives

struct BlockHorizontalRectangularView: View {
    
    let state: BlockHorizontalRectangularState
    let event: (Event) -> Void
    let factory: Factory
    let config: Config
    
    var body: some View {
        
        VStack(spacing: config.spacing) {
            ForEach(state.block.list, content: itemView)
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .padding(.horizontal, config.paddings.horizontal)
        .padding(.vertical, config.paddings.vertical)
    }
    
    @ViewBuilder
    private func itemView (item: Item) -> some View {
        if item.limitType == state.limitType {
            
            ItemView(
                item: item,
                inputStates: state.inputStates,
                config: config,
                factory: factory,
                event: event
            )
        }
    }
}

extension BlockHorizontalRectangularView {
    
    typealias Event = BlockHorizontalRectangularEvent
    typealias Factory = ViewFactory
    typealias Config = UILanding.BlockHorizontalRectangular.Config
    typealias Item = UILanding.BlockHorizontalRectangular.Item
}

extension BlockHorizontalRectangularView {
    
    struct ItemView: View {
        
        let item: Item
        let inputStates: [InputState]
        let config: Config
        let factory: Factory
        let event: (Event) -> Void
        
        var body: some View {
            
            ZStack {
                config.colors.background
                    .ignoresSafeArea()
                    .cornerRadius(config.cornerRadius)
                
                VStack(alignment: .leading) {
                    
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(config.colors.title)
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(config.colors.subtitle)
                    
                    ForEach(item.limits, id: \.id, content: limit)
                }
                .padding()
            }
        }
        
        private func limit(_ limit: Item.Limit) -> some View {
            
            if let inputState = inputStates.first(where: { $0.id == limit.id }) {
                return AnyView(VStack(alignment: .leading) {
                    
                    Text(limit.title)
                        .font(.headline)
                        .foregroundColor(config.colors.title)

                    VStack(alignment: .leading, spacing: 4) {

                        LimitSettingsWrapperView(
                            viewModel: .init(
                                initialState: .init(
                                    hiddenInfo: false,
                                    limit: .init(
                                        title: limit.text,
                                        value: limit.maxSum,
                                        md5Hash: limit.md5hash
                                    ), currencySymbol: "₽"),
                                reduce: {
                                    state, event in
                                    var state = state
                                    switch event {
                                    case let .edit(value):
                                        state.hiddenInfo = state.limit.value >= value
                                        state.newValue = value
                                    }
                                    return (state, .none)
                                },
                                handleEffect: {_,_ in }),
                            config: .preview,
                            infoView: {
                                Text("Сумма лимита не может быть больше \(limit.maxSum) ₽")
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.init(red: 227/255, green: 1/255, blue: 27/255))
                                    .font(.system(size: 12))
                            },
                            makeIconView: factory.makeIconView)
                                                
                        if limit != item.limits.last {
                            
                            HorizontalDivider(color: config.colors.divider)
                                .padding(.vertical, 0)
                        }
                    }
                })
            }
            else { return AnyView(EmptyView()) }
        }
    }
}

struct BlockHorizontalRectangularView_Previews: PreviewProvider {
    static var previews: some View {
        
        BlockHorizontalRectangularView(
            state: .init(
                block: .defaultValue,
                initialLimitsInfo: .init(type: "DEBIT_OPERATIONS", svCardLimits: nil)
            ),
            event: { _ in },
            factory: .default,
            config: .default)
    }
}
