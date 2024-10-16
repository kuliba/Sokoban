//
//  PlainClientInformBottomSheetView.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 04.10.2024.
//

import SwiftUI

struct PlainClientInformBottomSheetView: View {
    
    @ObservedObject var viewModel: PlainClientInformBottomSheetViewModel
    @State private var contentHeight: CGFloat = .zero
    let config: Config
    let info: Info

    var body: some View {
        ZStack(alignment: .top) {

            if viewModel.isShowNavBar {
                NavBarView()
                    .transition(.identity)
            }
            
            ScrollView(viewModel.axes, showsIndicators: false) {

                ContentStack()
                    .background(GeometryReader {
                        Color.clear.preference(key: ViewOffsetKey.self,
                                               value: -$0.frame(in: .named("scroll")).origin.y)
                    })
                    .onPreferenceChange(ViewOffsetKey.self) { value in
                        withAnimation(.linear(duration: 0.2)) {
                            viewModel.isShowNavBar = value > config.sizes.navBarHeight
                        }
                    }
            }
            .coordinateSpace(name: "scroll")
            .zIndex(-1)
        }
    }
    
    private func NavBarView() -> some View {
        
        ZStack(alignment: .top) {

            config.colors.grayBackground
                .frame(height: config.sizes.navBarHeight)
                .ignoresSafeArea()
            
            config.colors.grayGrabber
                .frame(
                    width: config.sizes.grabberWidth,
                    height: config.sizes.grabberHeight,
                    alignment: .top
                )
                .cornerRadius(config.sizes.grabberCornerRadius)
                .padding(.top, config.paddings.topGrabber)
                .ignoresSafeArea()
            
            switch info {
            case .single(let singleInfo):
                NavBarTitle(singleInfo.label.title)
            case .multiple(let multipleInfo):
                NavBarTitle(multipleInfo.title.title)
            }
        }
    }
    
    private func NavBarTitle(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .foregroundColor(.black)
            .padding(.horizontal, config.paddings.horizontal)
            .padding(.vertical, config.paddings.vertical)
            .frame(maxWidth: .infinity, maxHeight: config.sizes.navBarMaxWidth, alignment: .leading)
            .background(config.colors.grayBackground)
    }
    
    private func ContentStack() -> some View {
        
        VStack(spacing: config.sizes.spacing) {
            
            config.colors.grayGrabber
                .frame(
                    width: config.sizes.grabberWidth,
                    height: config.sizes.grabberHeight,
                    alignment: .top
                )
                .cornerRadius(config.sizes.grabberCornerRadius)
                .padding(.top, config.paddings.topGrabber)
                .ignoresSafeArea()
            
            switch info {
            case .single(let singleInfo):
                iconView(singleInfo.label.image)
                titleView(singleInfo.label.title)
                Text(singleInfo.text)
                    .font(config.fonts.navTitle)
                    .foregroundColor(config.colors.textSecondary)
            case .multiple(let multipleInfo):
                iconView(multipleInfo.title.image)
                titleView(multipleInfo.title.title)
                VStack(alignment: .leading, spacing: config.sizes.spacing) {
                    ForEach(multipleInfo.items) { item in
                        PlainClientInformRowView(
                            logo: item.image,
                            text: item.title,
                            config: config
                        )
                    }
                }
                .padding(.horizontal, config.paddings.horizontal)
            }

            
            
        }
    }
    
    private func iconView(_ image: Image) -> some View {
        image
            .resizable()
            .frame(width: config.sizes.iconSize, height: config.sizes.iconSize)
            .padding(.top, config.paddings.topImage)
    }
    
    private func titleView(_ text: String) -> some View {
        Text(text)
            .font(config.fonts.navTitle)
            .foregroundColor(config.colors.textSecondary)
    }

    func textView(_ text: Binding<AttributedString>) -> some View {
        Text(text.wrappedValue)
            .font(config.fonts.navTitle)
            .foregroundColor(config.colors.textSecondary)
    }
    
    struct ViewOffsetKey: PreferenceKey {
        
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value += nextValue()
        }
    }
}

extension PlainClientInformBottomSheetView {
    
    typealias Config = PlainClientInformBottomSheetConfig
    typealias Info = InfoModel
}

// MARK: - Preview
struct PlainClientInformBottomSheetView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PlainClientInformBottomSheetView(
            viewModel: .init(shouldScroll: true, info: .preview),
            config: .default, 
            info: .preview
        )
    }
}
