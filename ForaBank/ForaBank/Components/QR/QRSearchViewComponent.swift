//
//  QRSearchViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.12.2022.
//

import SwiftUI

struct QRSearchViewComponent: View {
    
    @Binding var text: String
    
    @State private var isEditing = false
    
    var textFieldPlaceholder: String
    var action: () -> Void
    
    var body: some View {
        
        HStack {
            
            TextField(textFieldPlaceholder, text: $text)
            
                .padding(7)
                .padding(.horizontal, 25)
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
                .overlay(
                    
                    HStack {
                        
                        Image.ic24Search
                            .foregroundColor(Color.bordersDivider)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            
                            Button(action: {
                                self.text = ""
                            }) {
                                Image.ic24Close
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .padding(.trailing, 8)
                                    .foregroundColor(Color.bGIconGreenLight)
                            }
                        }
                    }
                )
            
            if isEditing {
                
                Button(action: {
                    
                    self.isEditing = false
                    self.text = ""
                    self.action()
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    
                    Text("Отмена")
                        .foregroundColor(Color.textPlaceholder)
                        .font(Font.textBodyMR14180())
                }
                .padding(.trailing, 10)
                .animation(.default)
            }
        } .overlay(
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.bordersDivider, lineWidth: 1)
        )
    }
}
