//
//  CollateralLoanLandingWrapperView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetCollateralLandingUI
import DropDownTextListComponent
import CollateralLoanLandingGetShowcaseUI
import RxViewModel
import SwiftUI
import UIPrimitives

struct CollateralLoanLandingWrapperView: View {
    
    @Environment(\.openURL) var openURL

    let binder: GetCollateralLandingDomain.Binder
    let config: Config
    let factory: Factory
    let goToMain: () -> Void
    let makeOperationDetailInfoViewModel: MakeOperationDetailInfoViewModel

    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            content()
                .alert(
                    item: state.navigation?.alert,
                    content: makeAlert
                )
                .navigationDestination(
                    destination: state.navigation?.destination,
                    content: { destinationView(destination: $0) { event(.dismiss) }}
                )
                .bottomSheet(
                    sheet: state.navigation?.bottomSheet,
                    dismiss: { binder.flow.event(.dismiss) },
                    content: bottomSheetView
                )
        }
    }
    
    private func content() -> some View {
        
        ZStack(alignment: .top) {
            
            binder.flow.state.navigation?.informer.map(informerView)
                .zIndex(1)
            
            RxWrapperView(
                model: binder.content,
                makeContentView: makeContentView(state:event:)
            )
        }
    }
    
    private func makeContentView(
        state: State,
        event: @escaping (Event) -> Void
    ) -> some View {
        
        Group {
            
            switch state.product {
            case .none:
                Color.clear
                    .loader(isLoading: state.product == nil, color: .clear)
                
            case let .some(product):
                content(product, state, event)
            }
        }
        .onFirstAppear { event(.load(state.landingID)) }
    }
    
    private func content(
        _ product: GetCollateralLandingProduct,
        _ state: GetCollateralLandingDomain.State,
        _ event: @escaping (GetCollateralLandingDomain.Event) -> Void
    ) -> some View {
        
        GetCollateralLandingView(
            state: state,
            domainEvent: event,
            externalEvent: {
                switch $0 {
                case let .showCaseList(id):
                    binder.flow.event(.select(.showCaseList(id)))
                    
                case let .createDraftApplication(product):
                    let payload = state.payload(product)
                    binder.flow.event(.select(.createDraft(payload)))
                    
                case let .openDocument(link):
                    if let url = URL(string: link) {
                        openURL(url)
                    }
                }
            },
            config: .default,
            factory: .init(
                makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                makeImageViewWithURL: factory.makeImageViewWithURL,
                getPDFDocument: factory.getPDFDocument,
                formatCurrency: factory.formatCurrency
            )
        )
    }
    
    @ViewBuilder
    private func destinationView(
        destination: GetCollateralLandingDomain.Navigation.Destination,
        dissmiss: @escaping () -> Void
    ) -> some View {
        
        switch destination {
        case let .createDraft(binder):
            CreateDraftCollateralLoanApplicationWrapperView(
                binder: binder,
                config: .default,
                factory: .init(
                    makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                    makeImageViewWithURL: factory.makeImageViewWithURL,
                    getPDFDocument: factory.getPDFDocument,
                    formatCurrency: factory.formatCurrency
                ),
                goToMain: goToMain,
                makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel
            )
            .navigationBarWithBack(title: "Оформление заявки", dismiss: dissmiss)
        }
    }
    
    @ViewBuilder
    private func bottomSheetView(
        bottomSheet: GetCollateralLandingDomain.Navigation.BottomSheet
    ) -> some View {
        
        switch bottomSheet {
        case let .showBottomSheet(type):
            bottomSheetView(type)
        }
    }
    
    private func bottomSheetView(
            _ type: GetCollateralLandingDomain.State.BottomSheet.SheetType
        ) -> some View {
            
            GetCollateralLandingBottomSheetView(
                state: binder.content.state,
                event: handlePeriodsDomainEvent(_:),
                config: config.bottomSheet,
                factory: .init(
                    makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash,
                    makeImageViewWithURL: factory.makeImageViewWithURL,
                    getPDFDocument: factory.getPDFDocument,
                    formatCurrency: factory.formatCurrency
                ),
                type: type
            )
        }

    private func informerView(
        _ informerData: InformerData
    ) -> InformerView {
        
        .init(
            viewModel: .init(
                message: informerData.message,
                icon: informerData.icon.image,
                color: informerData.color)
        )
    }

    private func handlePeriodsDomainEvent(_ event: Event) {
        
        binder.content.event(event)
        // Делаем задержку закрытия, чтобы пользователь увидел на шторке выбранный айтем
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [binder] in
            binder.flow.event(.dismiss)
        }
    }
    
    private func handleCollateralsDomainEvent(_ event: Event) {
        
        binder.content.event(event)
        binder.flow.event(.dismiss)
    }
    
    private func makeAlert(
        alert: GetCollateralLandingDomain.Navigation.Alert
    ) -> SwiftUI.Alert {
        
        switch alert {
            
        case let .failure(failure):
            return .init(
                title: Text("Ошибка"),
                message: Text(failure),
                dismissButton: .default(Text("ОK")) { goToMain() }
            )
        }
    }
}
 
// MARK: UI mapping

extension GetCollateralLandingDomain.Navigation {
    
    var alert: Alert? {
        
        switch self {
        case let .failure(kind):
            switch kind {
            case let .alert(message):
                return .failure(message)
                
            default:
                return nil
            }
            
        default:
            return nil
        }
    }

    enum Alert {
        
        case failure(String)
    }

    var informer: GetCollateralLandingDomain.InformerPayload? {
        
        guard case let .failure(.informer(informer)) = self
        else { return nil }
        
        return informer
    }

    var destination: Destination? {
        
        switch self {
        case let .createDraft(binder):
            return .createDraft(binder)
            
        case .showBottomSheet, .failure:
            return nil
        }
    }
    
    enum Destination {
        
        case createDraft(Domain.Binder)
    }
    
    var bottomSheet: BottomSheet? {
        
            switch self {
            case .createDraft, .failure:
                return nil
                
            case let .showBottomSheet(id):
                return .showBottomSheet(id)
            }
    }
    
    enum BottomSheet {
        
        case showBottomSheet(GetCollateralLandingDomain.State.BottomSheet.SheetType)
    }
    
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
}

extension GetCollateralLandingDomain.Navigation.Destination: Identifiable {
    
    var id: ObjectIdentifier {
        
        switch self {
        case let .createDraft(binder): return .init(binder)
        }
    }
}

extension GetCollateralLandingDomain.Navigation.BottomSheet: Identifiable, BottomSheetCustomizable {
    
    var id: String {
        
        switch self {
        case let .showBottomSheet(id):
            switch id {
            case .periods:
                return "periods"
                
            case .collaterals:
                return "collaterals"
            }
        }
    }
}

extension GetCollateralLandingDomain.Navigation.Alert: Identifiable {
    
    var id: String {
        
        switch self {
        case let .failure(message):
            return message
        }
    }
}

extension GetCollateralLandingDomain {
    
    typealias Payload = CreateDraftCollateralLoanApplication
}

extension GetCollateralLandingConfig {
    
    static let `default` = Self(
        fonts: .default,
        backgroundImageHeight: 703,
        paddings: .default,
        spacing: 16,
        cornerRadius: 12,
        header: .default,
        conditions: .default,
        calculator: .default,
        faq: .default,
        documents: .default,
        footer: .default,
        bottomSheet: .default
    )
}

extension GetCollateralLandingConfig.Fonts {
    
    static let `default` = Self(
        body: .init(Font.system(size: 14))
    )
}

extension GetCollateralLandingConfig.Paddings {
    
    static let `default` = Self(
        outerLeading: 16,
        outerTrailing: 15,
        outerBottom: 110,
        outerTop: 16
    )
}

extension GetCollateralLandingConfig.Header {
    
    static let `default` = Self(
        height: 642,
        labelTag: .init(
            layouts: .init(
                cornerSize: 10,
                topOuterPadding: 215,
                leadingOuterPadding: 25,
                horizontalInnerPadding: 10,
                verticalInnerPadding: 6,
                rotationDegrees: -5
            ),
            fonts: .init(fontConfig: .init(
                Font.system(size: 32).bold(),
                foreground: .white,
                background: .red
            ))
        ),
        params: .init(
            fontConfig: .init(Font.system(size: 14)),
            spacing: 20,
            leadingPadding: 20,
            topPadding: 30
        )
    )
}

extension GetCollateralLandingConfig.Conditions {
    
    static let `default` = Self(
        header: .init(
            text: "Выгодные условия",
            headerFont: .init(Font.system(size: 18).bold())
        ),
        list: .init(
            layouts: .init(
                spacing: 13,
                horizontalPadding: 16,
                listTopPadding: 12,
                iconSize: CGSize(width: 40, height: 40),
                iconTrailingPadding: 16,
                subTitleTopPadding: 2
            ),
            fonts: .init(
                title: .init(Font.system(size: 14), foreground: .textPlaceholder),
                subTitle: .init(Font.system(size: 16))),
            colors: .init(
                background: .grayLightest,
                iconBackground: .iconBackground
            )
        )
    )
}

extension GetCollateralLandingConfig.Calculator {
    
    static let `default` = Self(
        root: .init(
            layouts: .init(
                height: 468,
                contentLeadingPadding: 16,
                contentTrailingPadding: 22,
                middleSectionSpacing: 11,
                spacingBetweenTitleAndValue: 8,
                chevronSpacing: 4,
                bottomPanelCornerRadius: 12,
                chevronOffsetY: 2
            ),
            fonts: .init(
                title: .init(Font.system(size: 12), foreground: .textPlaceholder),
                value: .init(Font.system(size: 16), foreground: .white)
            ),
            colors: .init(
                background: .black,
                divider: .divider,
                chevron: .divider,
                bottomPanelBackground: .bottomPanelBackground
            )
        ),
        header: .init(
            text: "Рассчитать кредит",
            font: .init(Font.system(size: 20).bold(), foreground: .white),
            topPadding: 16,
            bottomPadding: 12
        ),
        salary: .init(
            text: "Я получаю зарплату на счет в Инновациях-Бизнеса",
            font: .init(Font.system(size: 14), foreground: .white),
            leadingPadding: 16,
            trailingPadding: 17,
            bottomPadding: 18,
            toggleTrailingPadding: 22,
            toggle: .init(
                colors: .init(
                    on: .green,
                    off: .textPlaceholder
                )
            ),
            slider: .init(
                minTrackColor: .red,
                maxTrackColor: .textPlaceholder,
                thumbDiameter: 20,
                trackHeight: 2
            )
        ),
        period: .init(titleText: "Срок кредита"),
        percent: .init(titleText: "Процентная ставка"),
        desiredAmount: .init(
            titleText: "Желаемая сумма кредита",
            maxText: "До 15 млн. ₽",
            titleTopPadding: 20,
            sliderBottomPadding: 12,
            fontValue: .init(Font.system(size: 24).bold(), foreground: .white)
        ),
        monthlyPayment: .init(
            titleText: "Ежемесячный платеж",
            titleTopPadding: 16,
            valueTopPadding: 8
        ),
        info: .init(
            titleText: "Представленные параметры являются расчетными и носят справочный характер",
            titleTopPadding: 15,
            titleBottomPadding: 15
        ),
        deposit: .init(
            titleText: "Залог",
            titleTopPadding: 24
        )
    )
}

extension DropDownTextListConfig {
    
    static let `default` = Self(
        cornerRadius: 12,
        chevronDownImage: Image(systemName: "chevron.down"),
        layouts: .init(
            horizontalPadding: 16,
            verticalPadding: 12
        ),
        colors: .init(
            divider: .faqDivider,
            background: .grayLightest
        ),
        fonts: .init(
            title: .init(textFont: Font.system(size: 18).bold(), textColor: .primary),
            itemTitle: .init(textFont: Font.system(size: 14), textColor: .primary),
            itemSubtitle: .init(textFont: Font.system(size: 14), textColor: .textPlaceholder)
        )
    )
}

extension GetCollateralLandingConfig.Documents {
    
    static let `default` = Self(
        background: .grayLightest,
        topPadding: 16,
        header: .init(
            text: "Документы",
            headerFont: .init(Font.system(size: 18).bold())
        ),
        list: .init(
            defaultIcon: Image("file-text"),
            layouts: .init(
                horizontalPadding: 16,
                topPadding: 8,
                bottomPadding: 6,
                spacing: 13,
                iconTrailingPadding: 16,
                iconSize: .init(width: 20, height: 20)
            ),
            fonts: .init(
                title: .init(Font.system(size: 14))
            )
        )
    )
}

extension GetCollateralLandingConfig.Footer {
    
    static let `default` = Self(
        text: "Оформить заявку",
        font: .init(Font.system(size: 16).bold()),
        foreground: .white,
        background: .red,
        layouts: .init(
            height: 56,
            cornerRadius: 12,
            paddings: .init(top: 16, leading: 16, bottom: 0, trailing: 15)
        )
    )
}

extension GetCollateralLandingConfig.BottomSheet {
    
    static let `default` = Self(
        font: .init(Font.system(size: 16)),
        layouts: .init(
            spacing: 8,
            scrollThreshold: 6,
            sheetTopOffset: 100,
            sheetBottomOffset: 20,
            cellHeightCompensation: 8
        ),
        radioButton: .init(
            layouts: .init(
                size: .init(width: 24, height: 24),
                cellHeigh: 50,
                lineWidth: 1.25,
                ringDiameter: 20,
                circleDiameter: 10
            ),
            paddings: .init(
                horizontal: 18,
                vertical: 15
            ),
            colors: .init(
                unselected: .unselected,
                selected: .red
            )
        ),
        icon: .init(
            size: .init(width: 40, height: 40),
            horizontalPadding: 20,
            verticalPadding: 8,
            cellHeigh: 56
        ),
        divider: .init(
            leadingPadding: 55,
            trailingPadding: 15
        )    )
}

private extension Color {
    
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
    static let unselected: Self = .init(red: 0.92, green: 0.92, blue: 0.92)
    static let red: Self = .init(red: 1, green: 0.21, blue: 0.21)
    static let iconBackground: Self = .init(red: 0.5, green: 0.8, blue: 0.76)
    static let textPlaceholder: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let buttonPrimaryDisabled: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
    static let divider: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let bottomPanelBackground: Self = .init(red: 0.16, green: 0.16, blue: 0.16)
    static let faqDivider: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
}

extension CollateralLoanLandingWrapperView {
    
    typealias Factory = CollateralLoanLandingFactory
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias SaveConsentsResult = Domain.SaveConsentsResult
    typealias Config = GetCollateralLandingConfig
    typealias Payload = CollateralLandingApplicationSaveConsentsResult
    typealias MakeOperationDetailInfoViewModel = (Payload) -> OperationDetailInfoViewModel
    typealias Event = GetCollateralLandingDomain.Event<InformerData>
    typealias State = GetCollateralLandingDomain.State<InformerData>
    typealias Informer = GetCollateralLandingDomain.InformerPayload

    public typealias makeImageViewWithMD5Hash = (String) -> UIPrimitives.AsyncImage
    public typealias makeImageViewWithURL = (String) -> UIPrimitives.AsyncImage
}
