//
//  PreviewBottomSheetView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 30.05.2022.
//

import SwiftUI
import Combine

// MARK: - PreviewViewModel

class BottomSheetViewModel: ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()

    @Published var items: [BottomSheetItemViewModel]
    @Published var sheet: Sheet?

    private var bindings = Set<AnyCancellable>()

    init(items: [BottomSheetItemViewModel]) {

        self.items = items

        bind()
    }

    func bind() {

        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in

                switch action {
                case _ as BottomSheetViewModelAction.Tapped.Button:
                    sheet = .init(sheetType: .button)

                default:
                    break
                }
            }.store(in: &bindings)

        $items
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] items in

                for item in items {
                    item.action
                        .receive(on: DispatchQueue.main)
                        .sink {  action in

                            switch action {
                            case let payload as BottomSheetViewModelAction.Tapped.Item:
                                self.sheet = .init(sheetType: .item(payload.model))

                            default:
                                break
                            }
                        }.store(in: &bindings)
                }
            }.store(in: &bindings)
    }
}

extension BottomSheetViewModel {

    struct Sheet: Identifiable {

        let id = UUID()
        let sheetType: SheetType

        enum SheetType {
            case item(BottomSheetItemViewModel)
            case button
        }
    }
}

enum BottomSheetViewModelAction {

    enum Tapped {

        struct Item: Action {

            let model: BottomSheetItemViewModel
        }

        struct Button: Action {}
    }
}

// MARK: - ItemViewModel

class BottomSheetItemViewModel: Identifiable, ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()

    let id: String
    let title: String
    let icon: Image

    init(id: String = UUID().uuidString, title: String, icon: Image) {

        self.id = id
        self.title = title
        self.icon = icon
    }
}

// MARK: - Preview Item

struct PreviewBottomSheetView: View {

    @ObservedObject var viewModel: BottomSheetViewModel

    var body: some View {

        VStack(spacing: 16) {

            Button {

                viewModel.action.send(BottomSheetViewModelAction.Tapped.Button())

            } label: {

                ZStack {

                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.mainColorsGray, lineWidth: 1)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(height: 40)
                        .padding()

                    Text("Show bottom sheet")
                        .font(.textH4R16240())
                        .foregroundColor(.mainColorsGray)
                }
            }

            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.items) { viewModel in
                            ContentCellView(viewModel: viewModel)
                        }
                    }.padding()
                }
            }
        }.bottomSheet(item: $viewModel.sheet) {

            // onDismiss action

        } content: { sheet in

            switch sheet.sheetType {
            case .button:

                Color.mainColorsGrayLightest
                    .frame(height: 250)

            case let .item(model):

                ZStack {

                    Color.mainColorsGrayLightest
                        .frame(height: 250)

                    VStack(spacing: 20) {

                        model.icon
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.mainColorsGray)

                        Text(model.title)
                            .font(.textH3R18240())
                            .foregroundColor(.mainColorsGray)

                    }.padding(.bottom)
                }
            }
        }
    }
}

extension PreviewBottomSheetView {

    struct ContentCellView: View {

        @ObservedObject var viewModel: BottomSheetItemViewModel

        var body: some View {

            Button {

                viewModel.action.send(BottomSheetViewModelAction.Tapped.Item(model: viewModel))

            } label: {

                ZStack {

                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.mainColorsGray, lineWidth: 1)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .frame(width: 100, height: 100)

                    VStack(spacing: 18) {

                        viewModel.icon
                            .resizable()
                            .frame(width: 26, height: 26)
                            .foregroundColor(.mainColorsGray)

                        Text(viewModel.title)
                            .font(.textH4R16240())
                            .foregroundColor(.mainColorsGray)
                    }
                }
            }
        }
    }
}

// MARK: - Preview Presented

struct PresentedBottomSheetView: View {

    @State var isShowBottomSheet: Bool

    var body: some View {

        VStack(spacing: 16) {

            Button {

                withAnimation {
                    isShowBottomSheet.toggle()
                }
            } label: {

                Text("Show bottom sheet")
                    .font(.textH4R16240())
                    .foregroundColor(.mainColorsGray)
            }
        }.bottomSheet(isPresented: $isShowBottomSheet) {

            // onDismiss action

        } content: {

            Color.mainColorsGrayLightest
                .frame(height: 250)
        }
    }
}

// MARK: - Previews

struct PreviewBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {

            PreviewBottomSheetView(viewModel: .init(
                items: [
                    .init(title: "Dollar", icon: .init(systemName: "dollarsign.circle")),
                    .init(title: "Ruble", icon: .init(systemName: "rublesign.circle")),
                    .init(title: "Euro", icon: .init(systemName: "eurosign.circle")),
                    .init(title: "Bitcoin", icon: .init(systemName: "bitcoinsign.circle")),
                    .init(title: "Sterling", icon: .init(systemName: "sterlingsign.circle"))
                ]))

            PresentedBottomSheetView(isShowBottomSheet: false)
        }
    }
}
