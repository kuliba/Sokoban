//
//  ClientInformListView.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 04.10.2024.
//

import SwiftUI

public struct ClientInformListView: View {

    @State private var isShowNavBar = false
    @State private var shouldScroll = true
    @State private var contentHeight: CGFloat = 0
    private var axes: Axis.Set { return shouldScroll ? .vertical : [] }
    
    private let config: Config
    private let info: Info
    private let maxHeight = maxHeightWithSafeArea()

    public init(config: Config, info: Info) {
        
        self.config = config
        self.info = info
    }
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            if isShowNavBar {
                
                navBarView()
                    .transition(.identity)
                    .opacity(isShowNavBar ? 1 : 0)
            }
            
            ScrollView(axes, showsIndicators: false) {
                
                contentStack()
                    .background(GeometryReader {
                        Color.clear.preference(key: ContentHeightKey.self,
                                               value: -$0.frame(in: .named("scroll")).origin.y)
                    })
                    .onPreferenceChange(ContentHeightKey.self) { value in
                        
                        withAnimation(Animation.linear(duration: 0.3)) {
                            
                            isShowNavBar = value > config.sizes.navBarHeight + config.sizes.navBarHeight
                        }
                        shouldScroll = contentHeight > maxHeight
                    }
                    .readSize { contentHeight = $0.height }
            }
            .coordinateSpace(name: "scroll")
            .zIndex(-1)
            .frame(height: min(maxHeight, contentHeight))
        }
    }
    
    private func navBarView() -> some View {
        
        ZStack(alignment: .top) {

            Color.white
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
            .background(.white)
    }
    
    private func contentStack() -> some View {
        
        VStack(alignment: .center, spacing: config.sizes.spacing) {
                        
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
            
            let linkableText = singleInfo.url != nil ? 
            "\(singleInfo.text) \(singleInfo.url!)" : singleInfo.text
            
            Text(linkableText)
                .font(config.textConfig.textFont)
                .foregroundColor(config.titleConfig.textColor)
                .padding(.horizontal, config.paddings.horizontal)
        }
        .padding(.bottom, config.paddings.bottom)
        .frame(maxWidth: .infinity)
    }

    private func multipleInfoView(_ multipleInfo: Info.Multiple) -> some View {
        
        VStack(spacing: config.sizes.spacing) {
            
            if !isShowNavBar {
                
                iconView()
                titleView(multipleInfo.label.title)
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
            .padding(.vertical, isShowNavBar ? config.sizes.navBarHeight +
                     config.sizes.bigSpacing : 0)
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
            value += nextValue()
        }
    }
}

public extension ClientInformListView {
    
    typealias Config = ClientInformListConfig
    typealias Info = ClientInformListDataState
}

// MARK: - Preview
struct PlainClientInformView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ClientInformListView(
            config: .default, 
            info: .preview
        )
    }
}

public extension View {
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        
        background(
            
            GeometryReader { geometry in
                
                Color.clear
                    .preference(key: SizePreferenceKey.self,
                                value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

private extension ClientInformListView {
    
    static func maxHeightWithSafeArea() -> CGFloat {
        
        guard let window = UIApplication.shared.windows.first else { return UIScreen.main.bounds.height }
        
        let safeAreaInsets = window.safeAreaInsets
        return UIScreen.main.bounds.height - safeAreaInsets.top - 30
    }
}
