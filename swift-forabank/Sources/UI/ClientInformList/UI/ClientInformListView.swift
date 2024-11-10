//
//  ClientInformListView.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 04.10.2024.
//

import SwiftUI

@available(iOS 15, *)
public struct ClientInformListView: View {

    @State private var isShowNavBar = false
    @State private var shouldScroll = true
    @State private var contentHeight: CGFloat = 0
    private var axes: Axis.Set { return shouldScroll ? .vertical : [] }
    
    private let config: Config
    private let info: Info
    private let maxHeight = UIScreen.main.bounds.height - 100
    
    public init(config: Config, info: Info) {
        
        self.config = config
        self.info = info
    }
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            if isShowNavBar {
                
                navBarView()
                    .transition(.identity)
            }
            
            ScrollView(axes, showsIndicators: false) {
                
                contentStack()
                    .background(GeometryReader { geometry in
                        Color.clear
                            .preference(key: ContentHeightKey.self, value: geometry.size.height)
                    })
                
            }
            .coordinateSpace(name: "scroll")
            .zIndex(-1)
            .frame(height: maxHeight < contentHeight ? maxHeight : contentHeight)
            .onPreferenceChange(ContentHeightKey.self) { contentHeight in
                    
                self.contentHeight = (contentHeight < maxHeight / 2) ? 
                (maxHeight / 2) : contentHeight

                isShowNavBar = contentHeight > UIScreen.main.bounds.height
                shouldScroll = contentHeight > UIScreen.main.bounds.height
            }
        }
    }
    
    private func navBarView() -> some View {
        
        ZStack(alignment: .top) {

            config.colors.grayBackground
                .frame(height: config.sizes.navBarHeight)
                .ignoresSafeArea()
                        
            navBarTitle(info.navBarTitle())
        }
    }
    
    private func navBarTitle(_ text: String) -> some View {
        
        Text(text)
            .font(.largeTitle)
            .foregroundColor(.black)
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, config.paddings.vertical)
            .frame(maxWidth: .infinity, maxHeight: config.sizes.navBarMaxWidth, alignment: .leading)
            .background(config.colors.grayBackground)
    }
    
    private func contentStack() -> some View {
        
        VStack(spacing: config.sizes.spacing) {
                        
            switch info {
            case .single(let singleInfo):
                singleInfoView(singleInfo)
                
            case .multiple(let multipleInfo):
                multipleInfoView(multipleInfo)
            }
        }
    }

    private func singleInfoView(_ singleInfo: Info.Single) -> some View {
        
        VStack(alignment: .center, spacing: config.sizes.spacing) {
            
            iconView(singleInfo.label.image)
            titleView(singleInfo.label.title)
            
            Text(singleInfo.text)
                .font(config.textConfig.textFont)
                .foregroundColor(config.titleConfig.textColor)
                .padding(.horizontal, config.paddings.horizontal)
        }
    }

    private func multipleInfoView(_ multipleInfo: Info.Multiple) -> some View {
        
        VStack(spacing: config.sizes.spacing) {
            
            if !isShowNavBar {
                iconView()
                titleView(multipleInfo.title.title)
            }
            
            VStack(alignment: .leading, spacing: config.sizes.spacing) {
                
                ForEach(multipleInfo.items) { item in
                    
                    ClientInformRowView(
                        logo: item.image,
                        text: item.title,
                        config: config
                    )
                }
            }
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, isShowNavBar ? config.sizes.navBarHeight : 0)
        }
    }
    
    @ViewBuilder
    private func iconView(_ image: Image? = nil) -> some View {
        
        if let image {
            image
                .resizable()
                .frame(width: config.sizes.iconBackgroundSize, height: config.sizes.iconBackgroundSize)
                .padding(.top, config.paddings.topImage)
        } else {
            config.image
                .resizable()
                .frame(width: config.sizes.iconSize, height: config.sizes.iconSize)
                .foregroundColor(.white)
                .background(Circle().frame(width: config.sizes.iconBackgroundSize, height: config.sizes.iconBackgroundSize)
                .foregroundColor(config.colors.bgIconRedLight))
                .padding(.top, config.paddings.topImage)
        }
    }
    
    private func titleView(_ text: String) -> some View {
        
        Text(text)
            .font(config.titleConfig.textFont)
            .foregroundColor(config.titleConfig.textColor)
    }

    private func textView(_ text: Binding<AttributedString>) -> some View {
        
        Text(text.wrappedValue)
            .font(config.textConfig.textFont)
            .foregroundColor(config.textConfig.textColor)
    }
    
    private struct ContentHeightKey: PreferenceKey {
        
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

@available(iOS 15, *)
public extension ClientInformListView {
    
    typealias Config = ClientInformListConfig
    typealias Info = ClientInformListDataState
}

// MARK: - Preview
@available(iOS 15, *)
struct PlainClientInformView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ClientInformListView(
            config: .default, 
            info: .preview
        )
    }
}


////
////  ClientInformView.swift
////  ForaBank
////
////  Created by Dmitry Martynov on 31.01.2023.
////
//
//import SwiftUI
//
//struct ClientInformView: View {
//    
//    let viewModel: ClientInformViewModel
//    @State private var contentHeight: CGFloat = 0
//    @State private var isShowNavBar = false
//    
//    private let maxHeight = UIScreen.main.bounds.height - 100
//    
//    var body: some View {
//        
//        ZStack(alignment: .top) {
//            
//            if isShowNavBar {
//
//                Color.white.frame(height: 48)
//                    .opacity(isShowNavBar ? 1 : 0.999)
//
//                Text(viewModel.title)
//                    .font(.textH3Sb18240())
//                    .foregroundColor(.textSecondary)
//                    .padding(.bottom, 6)
//                    .padding()
//                    .frame(maxWidth: .infinity, maxHeight: 48, alignment: isShowNavBar ? .leading : .center)
//                    .background(Color.white)
//                    .opacity(isShowNavBar ? 1 : 0.999)
//            }
//        
//            ScrollView(.vertical, showsIndicators: false) {
//
//                VStack(spacing: 24) {
//                
//                    Circle()
//                        .foregroundColor(.bgIconGrayLightest)
//                        .frame(width: 64, height: 64)
//                        .overlay13 { Image.ic24Tool
//                                            .renderingMode(.original)
//                                            .resizable()
//                                            .frame(width: 40, height: 40)
//                        }.padding(.top, 10)
//                
//                    if !isShowNavBar {
//                    
//                        Text(viewModel.title)
//                            .font(.textH3Sb18240())
//                            .foregroundColor(.textSecondary)
//                    }
//                
//                    VStack(alignment: .leading, spacing: 24) {
//                    
//                        ForEach(viewModel.items) { item in
//                            ClientInformItemView(viewModel: item)
//                        }
//                    }
//                    .padding(.top, 8)
//                    .padding(.bottom, 40)
//                    .padding(.horizontal)
//                }
//                .background(GeometryReader {
//                    Color.clear.preference(key: ViewOffsetKey.self,
//                                           value: -$0.frame(in: .named("scroll")).origin.y)
//                })
//                .onPreferenceChange(ViewOffsetKey.self) { value in
//                    withAnimation(Animation.linear(duration: 0.3)) {
//                        isShowNavBar = value > 82
//                    }
//                
//                }
//                .readSize { contentHeight = $0.height }
//            }
//            .coordinateSpace(name: "scroll")
//            .frame(height: maxHeight < contentHeight ? maxHeight : contentHeight)
//            .zIndex(-1)
//            
//        }
//        
//    }
//    
//    struct ViewOffsetKey: PreferenceKey {
//        typealias Value = CGFloat
//        static var defaultValue = CGFloat.zero
//        static func reduce(value: inout Value, nextValue: () -> Value) {
//            value += nextValue()
//        }
//    }
//}
//
//struct ClientInformItemView: View {
//    
//    let viewModel: ClientInformViewModel.ClientInformItemViewModel
//    
//    var body: some View {
//        
//        HStack(alignment: .top, spacing: 20) {
//            
//            Circle()
//                .foregroundColor(.bgIconGrayLightest)
//                .frame(width: 40, height: 40)
//                .overlay13 { viewModel.icon }
//                
//            Text(viewModel.text)
//                .font(.textBodyMR14200())
//                .foregroundColor(.textSecondary)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//// MARK: - Preview
//struct ClientInformView_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        
//        ClientInformView(viewModel: .init(model: .emptyMock, items: ClientInformViewModel.sampleItemsMax))
//    }
//}

