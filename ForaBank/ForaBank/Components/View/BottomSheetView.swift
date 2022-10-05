//
//  BottomSheetView.swift
//  SwiftUiTest
//
//  Created by Max Gribov on 18.07.2022.
//

import SwiftUI
import Combine

protocol BottomSheetCustomizable: Identifiable {
    
    var keyboardOfssetMultiplier: CGFloat { get }
    var animationSpeed: Double { get }
}

extension BottomSheetCustomizable {
    
    var keyboardOfssetMultiplier: CGFloat { 0.6 }
    var animationSpeed: Double { 0.5 }
}

// MARK: - View Extensions

extension View {
    
    func bottomSheet<Content>(isPresented: Binding<Bool>, keyboardOfssetMultiplier: CGFloat = 0.6, animationSpeed: Double = 0.5, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        
        modifier(BottomSheetModifier(isPresented: isPresented, keyboardOfssetMultiplier: keyboardOfssetMultiplier, animationSpeed: animationSpeed, sheetContent: content))
    }
    
    func bottomSheet<Item, Content>(item: Binding<Item?>, keyboardOfssetMultiplier: CGFloat = 0.6, animationSpeed: Double = 0.5, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item : Identifiable, Content : View {
        
        modifier(BottomSheetItemModifier(item: item, keyboardOfssetMultiplier: keyboardOfssetMultiplier, animationSpeed: animationSpeed, sheetContent: content))
    }
    
    func bottomSheet<Item, Content>(item: Binding<Item?>, keyboardOfssetMultiplier: CGFloat = 0.6, animationSpeed: Double = 0.5, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item : BottomSheetCustomizable, Content : View {
        
        if let itemWrappedValue = item.wrappedValue {
            
            return modifier(BottomSheetItemModifier(item: item, keyboardOfssetMultiplier: itemWrappedValue.keyboardOfssetMultiplier, animationSpeed: itemWrappedValue.animationSpeed, sheetContent: content))
            
        } else {
            
            return modifier(BottomSheetItemModifier(item: item, keyboardOfssetMultiplier: keyboardOfssetMultiplier, animationSpeed: animationSpeed, sheetContent: content))
        }
    }
}

//MARK: - Bottom Sheet Modifier

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    
    let isPresented: Binding<Bool>
    let keyboardOfssetMultiplier: CGFloat
    let animationSpeed: Double
    let sheetContent: () -> SheetContent
    
    @ViewBuilder
    func body(content: Content) -> some View {
        
        if #available(iOS 14.0, *) {
            
            content
                .transaction({ transaction in
                    transaction.disablesAnimations = false
                })
                .fullScreenCover(isPresented: isPresented) {
                    BottomSheetView(isPresented: isPresented, keyboardOfssetMultiplier: keyboardOfssetMultiplier, animationSpeed: animationSpeed, content: sheetContent())
                }
                .transaction({ transaction in
                    transaction.disablesAnimations = true
                })
            
        } else {
            
            content.sheet(isPresented: isPresented, content: sheetContent)
        }
    }
}

struct BottomSheetItemModifier<SheetContent: View, Item: Identifiable>: ViewModifier {
    
    @Binding var item: Item?
    var isPresented: Binding<Bool>
    let keyboardOfssetMultiplier: CGFloat
    let animationSpeed: Double
    let sheetContent: (Item) -> SheetContent
    
    init(item: Binding<Item?>, keyboardOfssetMultiplier: CGFloat, animationSpeed: Double, @ViewBuilder sheetContent: @escaping (Item) -> SheetContent) {
        
        self._item = item
        self.keyboardOfssetMultiplier = keyboardOfssetMultiplier
        self.animationSpeed = animationSpeed
        self.sheetContent = sheetContent
        self.isPresented = Binding(get: { item.wrappedValue != nil }, set: { newValue in
            if newValue == false {
                item.wrappedValue = nil
            }
        })
    }
    
    func body(content: Content) -> some View {
        
        if item != nil {
            
            content
                .transaction({ transaction in
                    transaction.disablesAnimations = false
                })
                .fullScreenCover(item: $item, content: { item in
                    
                    BottomSheetView(isPresented: isPresented, keyboardOfssetMultiplier: keyboardOfssetMultiplier, animationSpeed: animationSpeed, content: sheetContent(item))
                    
                })
                .transaction({ transaction in
                    transaction.disablesAnimations = true
                })
            
        } else {
            
            content
        }
    }
}

//MARK: - Bottom Sheet View

struct BottomSheetView<Content: View>: View {
    
    @Binding var isPresented: Bool
    let keyboardOfssetMultiplier: CGFloat
    let animationSpeed: Double
    let content: Content
    
    @State private var isShutterPresented = false
    @State private var dimmProgress: CGFloat = 0
    @State private var contentSize: CGSize = .zero
    @State private var bottomPadding: CGFloat = 0
    @GestureState private var translation: CGFloat = 0
    @ObservedObject private var keyboardPublisher = KeyboardPublisher.shared
    
    init(isPresented: Binding<Bool>, keyboardOfssetMultiplier: CGFloat, animationSpeed: Double, content: Content) {
        
        self._isPresented = isPresented
        self.keyboardOfssetMultiplier = keyboardOfssetMultiplier
        self.animationSpeed = animationSpeed
        self.content = content
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            DimmView(isShutterPresented: $isShutterPresented, progress: $dimmProgress)
                .zIndex(0)
            
            if isShutterPresented {
                
                VStack(spacing: 0) {
                    
                    BottomSheetShutterView(isShutterPresented: $isShutterPresented, content: content)
                    
                    Color.white
                        .frame(width: UIScreen.main.bounds.width, height: max(keyboardPublisher.keyboardHeight * keyboardOfssetMultiplier, 0))
                    
                }
                .zIndex(1)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: BottomSheetPreferenceKey.self, value: proxy.size)
                    }
                )
                .onPreferenceChange(BottomSheetPreferenceKey.self, perform: { self.contentSize = $0 })
                .transition(.move(edge: .bottom))
                .animation(.interactiveSpring().speed(animationSpeed))
                .offset(y: max(translation, 0))
                .gesture(
                    DragGesture().updating(self.$translation) { value, state, _ in
                        state = value.translation.height
                        
                    }.onEnded { value in
                        
                        if value.translation.height > contentSize.height / 3 {
                            
                            isShutterPresented = false
                        }
                    }
                )
                
            } else {
                
                Color.clear
            }
        }
        .background(ClearBackgroundView())
        .ignoresSafeArea(.all, edges: .bottom)
        .ignoresSafeArea(.keyboard)
        .onAppear{
            withAnimation(.interactiveSpring().speed(0.5)) {
                isShutterPresented = true
                dimmProgress = 1.0
            }
        }
        .onChange(of: translation, perform: { newValue in
            
            guard contentSize.height > 0, newValue > 0 else {
                return
            }
            
            dimmProgress = 1 - max(newValue, 0) / contentSize.height
            UIApplication.shared.endEditing()
        })
        .onChange(of: isShutterPresented) { newValue in
            
            if newValue == false {
                
                withAnimation(.easeIn(duration: 0.3)) {
                    self.dimmProgress = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                    
                    self.isPresented = false
                }
            }
        }
    }
}

extension BottomSheetView {
    
    struct DimmView: View {
        
        @Binding var isShutterPresented: Bool
        @Binding var progress: CGFloat
        
        var body: some View {
            
            Color.black
                .opacity(0.3 * progress)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isShutterPresented = false
                }
        }
    }
    
    struct ClearBackgroundView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> UIViewController {
            
            let controller = UIViewController(nibName: nil, bundle: nil)
            
            context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
               
                vc.parent?.view.backgroundColor = .clear
            })
            
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            
        }
        
        class Coordinator {
            
            var parentObserver: NSKeyValueObservation?
        }
        
        func makeCoordinator() -> Self.Coordinator { Coordinator() }
    }
}

//MARK: - Shutter View

struct BottomSheetShutterView<Content: View>: View {
    
    @Binding var isShutterPresented: Bool
    let content: Content
    
    var body: some View {
        
        content
            .padding(.top, 29)
            .frame(width: UIScreen.main.bounds.width)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            .overlay(IndicatorView(isShutterPresented: $isShutterPresented).offset(x: 0, y: -14))
    }
}

extension BottomSheetShutterView {
    
    struct IndicatorView: View {
        
        @Binding var isShutterPresented: Bool
        
        var body: some View {
            
            VStack {
                
                ZStack {
                    
                    Color.init(white: 1.0, opacity: 0.01)
                    
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 48, height: 5)
                }
                .frame(width: UIScreen.main.bounds.width, height: 44)
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isShutterPresented = false
                    }
                }
                
                Spacer()
            }
        }
    }
}

//MARK: - Preference Keys

struct BottomSheetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        _ = nextValue()
    }
}

//MARK: - Previews

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {

            if #available(iOS 14.0, *) {

                BottomSheetView(isPresented: .constant(true), keyboardOfssetMultiplier: 0.5, animationSpeed: 0.5, content: Rectangle().fill(Color.red)
                    .frame(height: 500))
            }

            ZStack(alignment: .bottom) {
                Color.gray
                    .edgesIgnoringSafeArea(.all)
                BottomSheetShutterView(isShutterPresented: .constant(true), content: Text("Hello, World").frame(height: 300))
            }
        }
    }
}
