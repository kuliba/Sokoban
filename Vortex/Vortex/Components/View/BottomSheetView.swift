//
//  BottomSheetView.swift
//  SwiftUiTest
//
//  Created by Max Gribov on 18.07.2022.
//

import SwiftUI
import Combine
import BottomSheetComponent

protocol BottomSheetCustomizable: Identifiable {
    
    var animationSpeed: Double { get }
    var isUserInteractionEnabled: CurrentValueSubject<Bool, Never> { get }
}

extension BottomSheetCustomizable {
    
    var animationSpeed: Double { 0.5 }
    var isUserInteractionEnabled: CurrentValueSubject<Bool, Never> { .init(true) }
}

// MARK: - View Extensions

extension View {
    
    func bottomSheet<Item, Content>(
        item: Binding<Item?>,
        animationSpeed: Double = 0.5,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item : BottomSheetCustomizable, Content : View {
        
        return modifier(
            BottomSheetComponent.BottomSheetItemModifier(
                item: item,
                animationSpeed: item.wrappedValue?.animationSpeed ?? animationSpeed,
                sheetContent: content
            )
        )
    }
    
    func bottomSheetInteractiveDismissDisabled<Item, Content>(
        item: Binding<Item?>,
        animationSpeed: Double = 0.5,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item : BottomSheetCustomizable, Content : View {
        
        return modifier(
            BottomSheetItemModifier(
                item: item,
                animationSpeed: item.wrappedValue?.animationSpeed ?? animationSpeed,
                sheetContent: content
            )
        )
    }
}

//MARK: - Bottom Sheet Modifier

struct BottomSheetItemModifier<SheetContent: View, Item: BottomSheetCustomizable>: ViewModifier {
    
    @Binding var item: Item?
    var isPresented: Binding<Bool>
    let animationSpeed: Double
    let sheetContent: (Item) -> SheetContent
    
    @State private var isUserInteractionEnabled: Bool = true
    
    init(
        item: Binding<Item?>,
        animationSpeed: Double,
        @ViewBuilder sheetContent: @escaping (Item) -> SheetContent
    ) {
        
        self._item = item
        self.animationSpeed = animationSpeed
        self.sheetContent = sheetContent
        self.isPresented = Binding(get: { item.wrappedValue != nil }, set: { newValue in
            if newValue == false {
                item.wrappedValue = nil
            }
        })
    }
    
    func body(content: Content) -> some View {
        
        content
            .transaction({ transaction in
                transaction.disablesAnimations = false
            })
            .fullScreenCover(item: $item, content: { item in
                
                BottomSheetView(
                    isPresented: isPresented,
                    isUserInteractionEnabled: $isUserInteractionEnabled,
                    animationSpeed: animationSpeed,
                    content: sheetContent(item)
                )
                .onReceive(item.isUserInteractionEnabled) {
                    isUserInteractionEnabled = $0
                }
            })
            .transaction({ transaction in
                transaction.disablesAnimations = true
            })
    }
}

//MARK: - Bottom Sheet View

struct BottomSheetView<Content: View>: View {
    
    @Binding var isPresented: Bool
    @Binding private var isUserInteractionEnabled: Bool
    
    let animationSpeed: Double
    let content: Content
    
    @State private var isShutterPresented = false
    @State private var dimmProgress: CGFloat = 0
    @State private var contentSize: CGSize = .zero
    @State private var bottomPadding: CGFloat = 0
    @GestureState private var translation: CGFloat = 0
    
    init(isPresented: Binding<Bool>, isUserInteractionEnabled: Binding<Bool>, animationSpeed: Double, content: Content) {
        
        self._isPresented = isPresented
        self._isUserInteractionEnabled = isUserInteractionEnabled
        self.animationSpeed = animationSpeed
        self.content = content
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            DimmView(isShutterPresented: $isShutterPresented, progress: $dimmProgress, isUserInteractionEnabled: isUserInteractionEnabled)
                .zIndex(0)
            
            if isShutterPresented {
                
                BottomSheetShutterView(isShutterPresented: $isShutterPresented, isUserInteractionEnabled: isUserInteractionEnabled, content: content)
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
                                
                                guard isUserInteractionEnabled == true else {
                                    return
                                }
                                
                                isShutterPresented = false
                            }
                        }
                    )
                
            } else {
                
                Color.clear
            }
        }
        .background(ClearBackgroundView())
        .ignoresSafeArea(.container, edges: .bottom)
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
        
        let isUserInteractionEnabled: Bool
        
        var body: some View {
            
            Color.black
                .opacity(0.3 * progress)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture {
                    
                    guard isUserInteractionEnabled == true else {
                        return
                    }
                    
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
    let isUserInteractionEnabled: Bool
    
    let content: Content
    
    var body: some View {
        
        content
            .padding(.top, 29)
            .frame(width: UIScreen.main.bounds.width)
            .background(Color.white)
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            .overlay(IndicatorView(isShutterPresented: $isShutterPresented, isUserInteractionEnabled: isUserInteractionEnabled).offset(x: 0, y: -14))
    }
}

extension BottomSheetShutterView {
    
    struct IndicatorView: View {
        
        @Binding var isShutterPresented: Bool
        let isUserInteractionEnabled: Bool
        
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
                        
                        guard isUserInteractionEnabled == true else {
                            return
                        }
                        
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
            
            BottomSheetView(
                isPresented: .constant(true),
                isUserInteractionEnabled: .constant(true),
                animationSpeed: 0.5,
                content: Rectangle().fill(Color.red)
                    .frame(height: 500)
            )
            
            ZStack(alignment: .bottom) {
                
                Color.gray
                    .ignoresSafeArea(.all, edges: .all)
                
                BottomSheetShutterView(
                    isShutterPresented: .constant(true),
                    isUserInteractionEnabled: true,
                    content: Text("Hello, World").frame(height: 300)
                )
            }
        }
    }
}
