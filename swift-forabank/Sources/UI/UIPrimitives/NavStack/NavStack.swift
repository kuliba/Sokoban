//
//  NavStack.swift
//
//
//  Created by Igor Malyarov on 11.03.2024.
//

import SwiftUI

public struct NavStack<Destination, DestinationView: View>: View {
    
    @Binding var stack: [Destination]
    var destinationView: (Destination) -> DestinationView
    
    public init(
        stack: Binding<[Destination]>,
        @ViewBuilder destinationView: @escaping (Destination) -> DestinationView
    ) {
        self._stack = stack
        self.destinationView = destinationView
    }
    
    public var body: some View {
        
        stack
            .enumerated()
            .reversed()
            .reduce(NavDestination<Destination, DestinationView>.theEnd) { pushTo, new in
                
                let (index, screen) = new
                
                return .destination(
                    destinationView(screen),
                    pushTo: pushTo,
                    stack: $stack,
                    index: index
                )
            }
    }
}

private indirect enum NavDestination<Destination, DestinationView: View>: View {
    
    case destination(DestinationView, pushTo: NavDestination<Destination, DestinationView>, stack: Binding<[Destination]>, index: Int)
    case theEnd
    
    var body: some View {
        
        switch self {
        case let .destination(view, pushTo, stack, index):
            view
                .background(
                    NavigationLink(
                        destination: pushTo,
                        isActive: .init(
                            get: {
                                if case .theEnd = pushTo {
                                    return false
                                }
                                
                                return stack.wrappedValue.count > index + 1
                            },
                            set: {
                                guard !$0 else { return }
                                
                                stack.wrappedValue = .init(stack.wrappedValue.prefix(index + 1))
                            }
                        ),
                        label: EmptyView.init
                    ).hidden()
                )
            
        case .theEnd:
            EmptyView()
        }
    }
}

struct NavStackDemo: View {
    
    @State private var values = ["0"]
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            NavigationView {
                
                NavStack(
                    stack: $values,
                    destinationView: destinationView
                )
                .navigationBarTitleDisplayMode(.inline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text(values.joined(separator: ", "))
                .foregroundColor(.gray)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func destinationView(
        title: String
    ) -> some View {
        
        button(title) { values.append("\(values.count + 1)") }
            .navigationTitle(title)
    }
    
    private func button(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: { values.append("\(values.count)") }) {
            
            Text(title)
                .font(.title.bold())
                .padding(48)
                .background(Color.gray.opacity(0.15))
                .clipShape(Circle())
                .contentShape(Rectangle())
        }
    }
}

struct NavStackDemo_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavStackDemo()
    }
}
