//
//  ContextMenuView.swift
//  ForaBank
//
//  Created by Mikhail on 24.01.2022.
//

import SwiftUI

class ContextMenuViewModel: ObservableObject {
    let items: [MenuItemViewModel]
    
    internal init(items: [MenuItemViewModel]) {
        self.items = items
    }
}

extension ContextMenuViewModel {
    struct MenuItemViewModel: Identifiable {
        let id = UUID()
        let icon: Image
        let title: String
        let action: () -> Void
    }
}

struct ContextMenuView: View {
    
    var viewModel: ContextMenuViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.items) { item in
                Button {
                    item.action()
                } label: {
                    HStack {
                        item.icon
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                        Text(item.title)
                            .foregroundColor(.black)
                            .padding(.leading, 12)
                        Spacer()
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
            
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .foregroundColor(Color.white)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 0)
    }
}

struct ContextMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            ContextMenuView(
                viewModel: .example)
                .previewLayout(.fixed(width: 250, height: 240))
        }
    }
}

extension ContextMenuViewModel {
    
    static let example: ContextMenuViewModel = .init(
        items:[
            .init(icon: Image("bar-in-order"),
                  title: "Последовательность",
                  action: {
                      print("")
                  }),
            .init(icon: Image("grid"),
                  title: "Вид (Плитка)",
                  action: {
                      print("")
                  }),
            .init(icon: Image("trash_empty"),
                  title: "Удалить",
                  action: {
                      print("")
                  })
        ])
}

