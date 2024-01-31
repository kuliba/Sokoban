//
//  ThreeButtonsView.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import SwiftUI

struct ThreeButtonsView: View { // верстка
    
    let buttons: [CardGuardianState._Button] // state
    let event: (CardGuardian.ButtonTapped) -> Void
    let config: CardGuardian.Config
    
    var body: some View {
        
        VStack(alignment: .leading) {
            ForEach(buttons, id: \.self, content: buttonView)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .padding(.leading, 20)
        .padding(.trailing, 80)
        .border(.green)
    }
    
    private func buttonView(button: CardGuardianState._Button) -> some View {
        
        HStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center, spacing: 0) {             Image(systemName: "staroflife.circle.fill")
                    .frame(width: 24, height: 24)
            }
            .padding(8)
            .frame(width: 40, height: 40, alignment: .center)
            .background(Color(red: 0.96, green: 0.96, blue: 0.97))
            .cornerRadius(90)
            Button(action: {
                event(button.event)})  {
                    Text(button.title)
                      Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.yellow)
        }
    }
}

struct ThreeButtonsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ThreeButtonsView(
            buttons: .preview,
            event: { _ in },
            config: .default
        )
    }
}

private extension CardGuardian.Config {
    
    static let `default`: Self = .init()
}

private extension CardGuardianState._Button {
    
    static let one: Self = .init(event: .toggleLock, title: "One", icon: "", subtitle: "subtitle")
    static let two: Self = .init(event: .toggleLock, title: "Two", icon: "", subtitle: "subtitle")
    static let three: Self = .init(event: .toggleLock, title: "Three", icon: "", subtitle: "subtitle")
}

private extension Array where Element == CardGuardianState._Button {
    
    static let preview: Self = [.one, .two, .three]
}
