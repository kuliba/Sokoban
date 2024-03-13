//
//  SelectView.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

struct SelectView: View {
    
    let state: SelectState
    let event: (SelectEvent) -> Void
    let config: Config
    
    var body: some View {
        
        switch state {
        case .collapsed:
            
            HStack(spacing: 16) {
                
                Image.defaultIcon(
                    backgroundColor: config.backgroundIcon,
                    icon: config.icon
                )
                .cornerRadius(20)
                
                Text(config.title)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {}, label: {
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                })
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(12)
            
        case let .expanded(options):
            
            VStack(spacing: 20) {
                
                HStack(spacing: 16) {
                    
                    Image.defaultIcon(
                        backgroundColor: config.backgroundIcon,
                        icon: config.icon
                    )
                    .cornerRadius(20)
                    
                    VStack {
                        
                        HStack {
                            
                            config.title.text(withConfig: config.titleConfig)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        
                        HStack {
                            
                            Text(config.placeholder)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {}, label: {
                        
                        Image(systemName: "chevron.up")
                            .foregroundColor(.gray)
                    })
                }
                
                ScrollView(.vertical) {
                    
                    VStack(spacing: 20) {
                        
                        ForEach(options, id: \.id) { option in
                            
                            VStack {
                                
                                Button(action: {}) {
                                    
                                    HStack(spacing: 20) {
                                        
                                        Image.defaultIcon(
                                            backgroundColor: option.backgroundIcon,
                                            icon: option.icon
                                        )
                                        .cornerRadius(20)
                                        
                                        Text(option.title)
                                            .foregroundColor(.black)
                                        
                                        
                                        Spacer()
                                    }
                                }
                                
                                Color.gray
                                    .frame(width: .infinity, height: 1, alignment: .center)
                                    .opacity(0.2)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
            .padding(.top, 13)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(12)
            
        case let .selectedOption(option: option):
            
        }
    }
}

extension SelectView {
    
    struct Config {
        
        let title: String
        let titleConfig: TextConfig
        
        let placeholder: String
        let placeholderConfig: TextConfig
        
        let backgroundIcon: Color
        let icon: Image
    }
}

struct SelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        selectView(.collapsed)
            .previewDisplayName("collapse")
        
        selectView(.expanded(options: previewOptions()))
            .previewDisplayName("expanded")
        
        selectView(.expanded(options: previewOptions()))
            .previewDisplayName("selected option")
    }
    
    private static func selectView(
        _ state: SelectState
    ) -> some View {
        
        SelectView(
            state: state,
            event: { _ in },
            config: .init(
                title: "Тип услуги",
                titleConfig: .init(textFont: .title3, textColor: .black),
                placeholder: "Начните ввод для поиска",
                placeholderConfig: .init(textFont: .body, textColor: .gray),
                backgroundIcon: .black,
                icon: .init(systemName: "photo.artframe")
            ))
        .padding(.all, 20)
    }
    
    private static func previewOptions() -> [SelectState.Option] {
        
        return [
            .init(
                id: UUID().uuidString,
                title: "Имущественный налог",
                icon: .init(systemName: "house"),
                backgroundIcon: .purple
            ),
            .init(
                id: UUID().uuidString,
                title: "Транспортный налог",
                icon: .init(systemName: "car"),
                backgroundIcon: .blue.opacity(0.5)
            ),
            .init(
                id: UUID().uuidString,
                title: "Земельный налог",
                icon: .init(systemName: "square.dashed"),
                backgroundIcon: .purple.opacity(0.6)
            ),
            .init(
                id: UUID().uuidString,
                title: "Водный налог",
                icon: .init(systemName: "drop.degreesign"),
                backgroundIcon: .blue.opacity(0.3)
            )
        ]
    }
}
