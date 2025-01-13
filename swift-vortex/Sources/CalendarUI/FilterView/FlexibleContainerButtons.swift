//
//  FlexibleContainerButtons.swift
//
//
//  Created by Дмитрий Савушкин on 20.09.2024.
//

import SwiftUI
import SharedConfigs

struct FlexibleContainerButtons: View {
    
    let data: [String]
    var selectedItems: Set<String>
    let serviceButtonTapped: (String) -> Void
    let config: ServiceButton.Config
    
    var body: some View {
        
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {
                
                ForEach(data, id: \.self) { service in
                    
                    ServiceButton(
                        state: .init(isSelected: selectedItems.contains(service)),
                        action: serviceButtonTapped,
                        config: .init(
                            title: service,
                            titleConfig: .init(
                                textFont: .system(size: 16),
                                textColor: .white
                            ))
                    )
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        
                        let result = width
                        if service == data.last! {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if service == data.last! {
                            height = 0
                        }
                        return result
                    })
                }
            }
        }
    }
}

struct ServiceButton: View {
    
    let state: State
    let action: (String) -> Void
    let config: Config
    
    var body: some View {
        
        Button(action: { action(self.config.title) }) {
            
            Text(config.title)
                .padding()
                .background(state.isSelected ? Color.black : .gray.opacity(0.2))
                .foregroundColor(state.isSelected ? .white : .black)
                .frame(height: 32)
                .cornerRadius(90)
        }
    }
    
    struct State {
        
        let isSelected: Bool
    }
    
    struct Config {
        
        let title: String
        let titleConfig: TextConfig
    }
}

extension View {
    
    @ViewBuilder func serviceButtonAlignmentGuide(
        data: [String],
        service: String,
        geometry: GeometryProxy
    ) -> some View {
        
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        self
            .alignmentGuide(.leading, computeValue: { dimension in
                if abs(width - dimension.width) > geometry.size.width {
                    width = 0
                    height -= dimension.height
                }
                
                let result = width
                if service == data.last {
                    width = 0
                } else {
                    width -= dimension.width
                }
                return result
            })
            .alignmentGuide(.top, computeValue: { _ in
                let result = height
                if service == data.last {
                    height = 0
                }
                return result
            })
    }
}
