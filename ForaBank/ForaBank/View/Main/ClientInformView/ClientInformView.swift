//
//  ClientInformView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 31.01.2023.
//

import SwiftUI

struct ClientInformView: View {
    
    let viewModel: ClientInformViewModel
    @State private var contentHeight: CGFloat = 0
    @State private var isShowNavBar = false
    
    private let maxHeight = UIScreen.main.bounds.height - 100
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            if isShowNavBar {

                Color.white.frame(height: 48)
                    .opacity(isShowNavBar ? 1 : 0.999)

                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.textSecondary)
                    .padding(.bottom, 6)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 48, alignment: isShowNavBar ? .leading : .center)
                    .background(Color.white)
                    .opacity(isShowNavBar ? 1 : 0.999)
            }
        
            ScrollView(.vertical, showsIndicators: false) {

                VStack(spacing: 24) {
                
                    Circle()
                        .foregroundColor(.bGIconGrayLightest)
                        .frame(width: 64, height: 64)
                        .overlay13 { Image.ic24Tool
                                            .renderingMode(.original)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                        }.padding(.top, 10)
                
                    if !isShowNavBar {
                    
                        Text(viewModel.title)
                            .font(.textH3SB18240())
                            .foregroundColor(.textSecondary)
                    }
                
                    VStack(alignment: .leading, spacing: 24) {
                    
                        ForEach(viewModel.items) { item in
                            ClientInformItemView(viewModel: item)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                    .padding(.horizontal)
                }
                .background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                                           value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    withAnimation(Animation.linear(duration: 0.3)) {
                        isShowNavBar = value > 82
                    }
                
                }
                .readSize { contentHeight = $0.height }
            }
            .coordinateSpace(name: "scroll")
            .frame(height: maxHeight < contentHeight ? maxHeight : contentHeight)
            .zIndex(-1)
            
        }
        
    }
    
    struct ViewOffsetKey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

struct ClientInformItemView: View {
    
    let viewModel: ClientInformViewModel.ClientInformItemViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 20) {
            
            Circle()
                .foregroundColor(.bGIconGrayLightest)
                .frame(width: 40, height: 40)
                .overlay13 { viewModel.icon }
                
            Text(viewModel.text)
                .font(.textBodyMR14200())
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
struct ClientInformView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ClientInformView(viewModel: .init(model: .emptyMock, items: ClientInformViewModel.sampleItemsMax))
    }
}


