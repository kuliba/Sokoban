//
//  HistoryViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI
import Combine
import UIPrimitives
import CalendarUI

//MARK: - ViewModel

extension ProductProfileHistoryView {
    
    class ViewModel: ObservableObject, Identifiable {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        var id: ProductData.ID { productId }
        let productId: ProductData.ID
        
        //TODO: button action
        
        lazy var header: HeaderViewModel = HeaderViewModel(button: .init(action: {}))
        
        @Published var segmentBarViewModel: SegmentedBarView.ViewModel?
        @Published var content: Content
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        private let filter: () -> FilterState?
        
        init(
            productId: ProductData.ID,
            state: Content,
            model: Model = .emptyMock,
            segmentBarVM: SegmentedBarView.ViewModel? = .spending,
            filter: @escaping () -> FilterState?
        ) {
            
            self.productId = productId
            self.content = state
            self.model = model
            self.segmentBarViewModel = segmentBarVM
            self.filter = filter
        }
        
        init(
            _ model: Model,
            productId: ProductData.ID,
            filter: @escaping () -> FilterState?
        ) {
            
            self.productId = productId
            self.content = .loading
            self.model = model
            self.filter = filter
            
            bind()
            action.send(ProductProfileHistoryViewModelAction.DownloadLatest())
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductProfileHistoryViewModelAction.DownloadLatest:
                        model.action.send(ModelAction.Statement.List.Request(
                            productId: productId,
                            direction: .latest,
                            operationType: nil,
                            category: nil
                        ))
                        
                    case _ as ProductProfileHistoryViewModelAction.DidTapped.More:
                        model.action.send(ModelAction.Statement.List.Request(
                            productId: productId,
                            direction: .eldest,
                            operationType: nil,
                            category: nil
                        ))
                        
                    case let payload as ProductProfileHistoryViewModelAction.Filter:
                        guard let storage = model.statements.value[id] else {
                            return
                        }
                        
                        var storageData: [ProductStatementData]
                        let filter = filter()
                        storageData = storage.statements
                        
                        if filter?.filter.selectedTransaction != nil {
                            
                            switch filter?.filter.selectedTransaction {
                            case .debit:
                                storageData = storage.statements.filter({
                                    $0.isDebitType
                                })
                            case .credit:
                                storageData = storage.statements.filter({
                                    $0.isCreditType
                                })
                            case .none:
                                break
                            }
                        }
                        
                        if payload.filterState?.filter.selectedPeriod != nil, payload.filterState?.filter.selectDates != nil {
                            
                            switch payload.filterState?.filter.selectedPeriod {
                            case .week:
                                storageData = storageData.filter({
                                    $0.dateValue.isBetweenStartDate(.startOfWeek ?? Date(), endDateInclusive: Date())
                                })
                                
                            case .month:
                                storageData = storageData.filter({
                                    $0.dateValue.isBetweenStartDate(Date(), endDateInclusive: Date().start(of: .month))
                                })
                            case .dates:
                                storageData = storageData.filter({
                                    $0.dateValue.isBetweenStartDate(payload.period.lowerDate ?? Date(), endDateInclusive: payload.period.upperDate ?? Date())
                                })
                            case .none:
                                break
                            }
                        }
                        
                        if let services = filter?.filter.selectedServices, services.count >= 1 {
                            
                            storageData = storageData.filter({ item in
                                return item.groupName.contained(in: filter?.filter.selectedServices.sorted() ?? [])
                            })
                            
                        }
                        
                        if let lowerDate = payload.period.lowerDate,
                           let upperDate = payload.period.upperDate {
                            
                            storageData = storageData.filter({
                                $0.dateValue.localDate().isBetweenStartDate(lowerDate, endDateInclusive: upperDate)
                            })
                        }
                        
                        updateContent(with: .idle, storage: storage)
                        
                        let update = reduce(
                            content: content,
                            statements: storageData,
                            images: model.images.value,
                            model: model
                        ) { [weak self] statementId in
                            {
                                self?.action.send(ProductProfileHistoryViewModelAction.DidTapped.Detail(statementId: statementId))
                            }
                        }

                        updateContent(with: update.groups)
                        
                        updateSegmentedBar(
                            productId: id,
                            statements: storageData,
                            selectRange: filter?.filter.selectDates ?? filter?.calendar.selectedRange
                        )
                        
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            model.statements
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] storages in
                    
                    guard let storage = storages[id] else {
                        return
                    }
                    
                    var storageStatements: [ProductStatementData] = storage.statements
                    if let filter = filter(),
                       (filter.calendar.selectedRange != nil || filter.filter.selectDates != nil) {
                        
                        if let lowerDate = filter.calendar.range?.lowerDate,
                           let upperDate = filter.calendar.range?.upperDate {
                            
                            storageStatements = storage.statements.filter({
                                
                                print($0.dateValue.localDate())
                                return $0.dateValue.localDate().isBetweenStartDate(lowerDate, endDateInclusive: upperDate)
                            })
                        }
                        if filter.filter.selectedTransaction != nil {
                            
                            switch filter.filter.selectedTransaction {
                            case .debit:
                                storageStatements = storageStatements.filter({
                                    $0.isDebitType
                                })
                            case .credit:
                                storageStatements = storageStatements.filter({
                                    $0.isCreditType
                                })
                            case .none:
                                break
                            }
                        }
                        
                        if filter.filter.selectDates != nil,
                           let selectPeriod = filter.filter.selectedPeriod {
                            
                            switch selectPeriod {
                            case .week:
                                storageStatements = storageStatements.filter({
                                    $0.dateValue.isBetweenStartDate(.startOfWeek ?? Date(), endDateInclusive: Date())
                                })
                                
                            case .month:
                                storageStatements = storageStatements.filter({
                                    $0.dateValue.isBetweenStartDate(Date(), endDateInclusive: Date().start(of: .month))
                                })
                            case .dates:
                                storageStatements = storageStatements.filter({
                                    
                                    $0.dateValue.isBetweenStartDate(filter.filter.selectDates?.lowerBound ?? Date(), endDateInclusive: filter.filter.selectDates?.upperBound ?? Date())
                                })
                            }
                        }
                        
                        if filter.filter.selectedServices.count >= 1 {
                            
                            storageStatements = storageStatements.filter({ item in
                                return item.groupName.contained(in: filter.filter.selectedServices.sorted())
                            })
                        }
                    }
                    
                    // isMapped = false  это согласованный костыль
                    updateSegmentedBar(
                        productId: id,
                        statements: storageStatements,
                        selectRange: filter()?.filter.selectDates ?? filter()?.calendar.selectedRange,
                        isMapped: false
                    )
                    
                    let update = reduce(
                        content: content,
                        statements: storageStatements,
                        images: model.images.value,
                        model: model
                    ) { [weak self] statementId in
                        {
                            self?.action.send(ProductProfileHistoryViewModelAction.DidTapped.Detail(statementId: statementId))
                        }
                    }
                    
                    updateContent(with: update.groups)
                    
                    if let state = model.statementsUpdating.value[id] {
                        
                        if filter()?.filter.selectDates?.lowerBound != nil || filter()?.calendar.range?.upperDate != nil {
                            updateContent(with: .downloading(.custom(start: filter()?.filter.selectDates?.lowerBound ?? Date(), end: filter()?.filter.selectDates?.upperBound ?? Date())), storage: storage)
                            
                        } else {
                            updateContent(with: state, storage: storage)
                        }
                    }
                    
                    if update.downloadImagesIds.isEmpty == false {
                        
                        model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: update.downloadImagesIds))
                    }
                }.store(in: &bindings)
            
            model.statementsUpdating
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] states in
                    
                    guard let state = states[id], let storage = model.statements.value[id] else {
                        return
                    }
                    
                    updateContent(with: state, storage: storage)

                }.store(in: &bindings)
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] images in
                    
                    guard !images.isEmpty,
                          case .list(let historyListViewModel) = content
                    else { return }
                    
                    let operations = historyListViewModel.groups
                        .flatMap {
                            $0.operations.filter { $0.image == nil }
                        }
                    
                    for operation in operations {
                        
//                        withAnimation {
                            operation.image = images[operation.statement.imageId]?.image
//                        }
                    }
                }
                .store(in: &bindings)
        }
        
        func updateSegmentedBar(
            productId: ProductData.ID,
            statements: [ProductStatementData],
            selectRange: ClosedRange<Date>?,
            isMapped: Bool = true
        ) {
            
            guard let product = model.product(productId: productId) else { return }
                
            let statementFilteredOperation: [ProductStatementData]
            
            switch product.productType {
            case .deposit:
                
                statementFilteredOperation = statements
                    .filter {
                        ($0.operationType == .credit || $0.operationType == .creditPlan) && $0.groupName == "Выплата процентов"
                    }
                
            case .account, .card:
                
                statementFilteredOperation = statements
                    .filter {
                        $0.operationType == .debit || $0.operationType == .debitPlan
                    }
                
            case .loan: return
            }
            
            var statementFilteredPeriod = statementFilteredOperation
            
            if let selectRange {
                
                statementFilteredPeriod = statementFilteredPeriod
                    .filter {
                        $0.dateValue.isBetweenStartDate(selectRange.lowerBound, endDateInclusive: selectRange.upperBound)
                    }
                
            } else {
                statementFilteredPeriod = statementFilteredPeriod
                    .filter { Calendar.current.isInMonth($0.dateValue)}
            }
            
            if isMapped {
                
                let dict = statementFilteredPeriod
                    .reduce(into: [ProductStatementMerchantGroup: Double]()) {
                        if let documentAmount = $1.documentAmount {
                            
                            $0[.init($1.groupName), default: 0] += documentAmount
                        }
                    }
                
                Task { @MainActor in
                    
                    segmentBarViewModel = .init(
                        mappedValues: dict,
                        productType: product.productType,
                        currencyCode: product.currency,
                        selectRange: selectRange,
                        model: model
                    )
                }
                
            } else {
                
                let dict = statementFilteredPeriod
                    .reduce(into: [ String: Double]()) {
                        if let documentAmount = $1.documentAmount {
                            
                            $0[$1.groupName, default: 0] += documentAmount
                        }
                    }
                
                Task { @MainActor in
                    
                    segmentBarViewModel = .init(
                        stringValues: dict,
                        productType: product.productType,
                        currencyCode: product.currency,
                        selectRange: selectRange,
                        model: model
                    )
                }
                
            }
        }
        
        func updateContent(
            with groups: [HistoryListViewModel.DayGroupViewModel]
        ) {
            guard !groups.isEmpty else {
                return content = .empty(.init())
            }
            
            if case let .list(historyListViewModel) = content {
                
//                withAnimation {
                    
                    historyListViewModel.groups = groups
//                }
                
            } else {
                
                let listViewModel = HistoryListViewModel(
                    expences: nil,
                    latestUpdate: nil,
                    groups: groups,
                    eldestUpdate: nil
                )
                
//                withAnimation {
                    
                    content = .list(listViewModel)
//                }
            }
        }
        
        func updateContent(
            with state: ProductStatementsUpdateState,
            storage: ProductStatementsStorage
        ) {
            
//            withAnimation {
                
                switch state {
                case .idle:
                    switch content {
                    case let .list(listViewModel):
                        listViewModel.latestUpdate = nil
                        let isFilterApplied = (filter()?.filter.isFilterApplied == true)
                        
                        if storage.hasMoreHistoryToShow,    
                           !isFilterApplied {
                            
                            listViewModel.eldestUpdate = .more(.init(
                                title: "Смотреть еще",
                                style: .red,
                                action: { [weak self] in self?.action.send(ProductProfileHistoryViewModelAction.DidTapped.More())} )
                            )
                            
                        } else {
                            
                            listViewModel.eldestUpdate = nil
                        }
                    default:
                        break
                    }
                    
                case let .downloading(downloadingType):
                    switch content {
                    case let .list(listViewModel):
                        switch downloadingType {
                        case .latest:
                            listViewModel.latestUpdate = .updating
                            listViewModel.eldestUpdate = nil
                            
                        case .eldest:
                            listViewModel.latestUpdate = nil
                            listViewModel.eldestUpdate = .updating
                            
                        case let .custom(start: startDate, end: endDate):
                            listViewModel.latestUpdate = nil
                            listViewModel.eldestUpdate = nil
                        }
       
                    default:
                        content = .loading
                    }
                    
                case .failed:
                    switch content {
                    case let .list(listViewModel):
                        if listViewModel.latestUpdate != nil {
                            
                            let formatter = DateFormatter.historyDateAndTimeFormatter
                            let endDateString = formatter.string(from: storage.period.end)
                            let failViewModel = HistoryListViewModel.LatestUpdateState.FailViewModel(title: "Ошибка! Попробуйте позже.", subtitle: "Отражены данные на \(endDateString)")
                            listViewModel.latestUpdate = .fail(failViewModel)
                        }
                        listViewModel.eldestUpdate = nil
                        
                    default:
                       break
                    }
                }
            }
//        }
    }
}

extension Calendar {
 
    func isInMonth(
        _ date: Date,
        of currentDate: Date = .init()
    ) -> Bool {
        
        dateComponents([.year, .month], from: date)
            == dateComponents([.year, .month], from: currentDate)
    }
}

//MARK: - Reducers

extension ProductProfileHistoryView.ViewModel {
    
    func reduce(content: Content, statements: [ProductStatementData], images: [String: ImageData], model: Model, shortDateFormatter: DateFormatter = .historyShortDateFormatter, fullDateFormatter: DateFormatter = .historyFullDateFormatter, action: (ProductStatementData.ID) -> () -> Void) -> (groups: [HistoryListViewModel.DayGroupViewModel], downloadImagesIds: [String]) {
        
        switch content {
        case .list(let historyListViewModel):
            
            return reduce(groups: historyListViewModel.groups, statements: statements, images: images, model: model, action: action)
            
        default:
            
            return reduce(groups: [], statements: statements, images: images, model: model, action: action)
        }
    }
    
    func reduce(groups: [HistoryListViewModel.DayGroupViewModel], statements: [ProductStatementData], images: [String: ImageData], model: Model, shortDateFormatter: DateFormatter = .historyShortDateFormatter, fullDateFormatter: DateFormatter = .historyFullDateFormatter, action: (ProductStatementData.ID) -> () -> Void) -> (groups: [HistoryListViewModel.DayGroupViewModel], downloadImagesIds: [String]) {
        
        func groupDateFormatted(date: Date) -> String {
            
            let dateYear = calendar.component(.year, from: date)
            
            return dateYear == currentYear ? shortDateFormatter.string(from: date) : fullDateFormatter.string(from: date)
        }
        
        let operations = groups.flatMap{ $0.operations }
        let operationsUpdateResult = reduce(operations: operations, statements: statements, images: images, model: model, action: action)
        
        let grouppedOperations = Dictionary(grouping: operationsUpdateResult.operations, by: { $0.statement.date.groupDayIndex }).sorted(by: { $0.0 > $1.0 })
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        var groupsResult = [HistoryListViewModel.DayGroupViewModel]()
        
        for group in grouppedOperations {
            
            let date = group.value[0].statement.date
            let dateString = groupDateFormatted(date: date)
            
            groupsResult.append(HistoryListViewModel.DayGroupViewModel(
                id: group.key,
                title: dateString,
                operations: group.value
            ))
        }
        
        return (groupsResult, operationsUpdateResult.downloadImagesIds)
    }
    
    func reduce(operations: [HistoryListViewModel.DayGroupViewModel.Operation], statements: [ProductStatementData], images: [String: ImageData], model: Model, action: (ProductStatementData.ID) -> () -> Void) -> (operations: [HistoryListViewModel.DayGroupViewModel.Operation], downloadImagesIds: [String]) {
        
        var updatedOperations = [HistoryListViewModel.DayGroupViewModel.Operation]()
        var downloadImagesIds = [String]()
        let groupedStatements = Dictionary(grouping: statements, by: { $0.operationId })
        
        for (_, statementsGroup) in groupedStatements {
            
            if let latestStatement = statementsGroup.max(by: {
                
                if let lhsTranDate = $0.tranDate, let rhsTranDate = $1.tranDate {
                    return lhsTranDate > rhsTranDate
                    
                } else {
                    return $0.date > $1.date
                }
            }) {
                
                let operation = HistoryListViewModel.DayGroupViewModel.Operation(statement: latestStatement, model: model, action: action(latestStatement.id))
                updatedOperations.append(operation)
                
                let imageId = latestStatement.md5hash
                if let imageData = images[imageId] {
                    operation.image = imageData.image
                    
                } else {
                    downloadImagesIds.append(imageId)
                }
            }
        }
        
        let sortedUpdatedOperations = updatedOperations.sorted(by: { $0.statement.date > $1.statement.date })
        
        return (sortedUpdatedOperations, downloadImagesIds)
    }
}

//MARK: - Action

enum ProductProfileHistoryViewModelAction {
    
    enum DidTapped {
   
        struct Detail: Action {
            
            let statementId: ProductStatementData.ID
        }
        
        struct More: Action {}
    }
    
    struct DownloadLatest: Action {}
    
    struct Filter: Action {
        
        let filterState: FilterState?
        let period: (lowerDate: Date?, upperDate: Date?)
    }
}

//MARK: - Types

extension ProductProfileHistoryView.ViewModel.Content {
    
    var amounts: [Double]? {
        guard case let .list(list) = self else { return nil }
        return list.expences?.amounts
    }
}

extension ProductProfileViewModel {

    var amounts: [Double]? {
     
        history?.content.amounts
    }
}

extension ProductProfileHistoryView.ViewModel {
    
    struct HeaderViewModel {
        
        let title = "История операций"
        let button: ButtonViewModel
        
        struct ButtonViewModel {
            
            let icon = Image.ic16Sliders
            let action: () -> Void
        }
    }
    
    enum Content {
        
        case empty(EmptyListViewModel)
        case list(HistoryListViewModel)
        case loading
    }
    
    struct EmptyListViewModel {
        
        let title = "Нет операций"
        let image = Image.ic24Search
    }
    
    class HistoryListViewModel: ObservableObject {
        
        @Published var expences: MonthExpencesViewModel?
        @Published var latestUpdate: LatestUpdateState?
        @Published var groups: [DayGroupViewModel]
        @Published var eldestUpdate: EldestUpdateState?
        
        init(
            expences: MonthExpencesViewModel?,
            latestUpdate: LatestUpdateState?,
            groups: [DayGroupViewModel],
            eldestUpdate: EldestUpdateState?
        ) {
            
            self.expences = expences
            self.latestUpdate = latestUpdate
            self.groups = groups
            self.eldestUpdate = eldestUpdate
        }
        
        struct MonthExpencesViewModel {
            
            let title: String
            let total: String
            let amounts: [Double]
        }
        
        enum LatestUpdateState {
            
            case updating
            case fail(FailViewModel)
            
            struct FailViewModel {
                
                let title: String
                let subtitle: String
            }
        }

        enum EldestUpdateState {
            
            case more(ButtonSimpleView.ViewModel)
            case updating
        }
        
        struct DayGroupViewModel: Identifiable {
            
            let id: Int
            let title: String
            let operations: [Operation]
            
            init(id: Int, title: String, operations: [Operation]) {
                
                self.id = id
                self.title = title
                self.operations = operations
            }
            
            class Operation: Identifiable, ObservableObject {
                
                var id: Int { statement.id }
                let statement: StatementBasicData
                let title: String
                @Published var image: Image?
                let subtitle: String
                let amount: Amount?
                let amountStatusImage: Image?
                let action: () -> Void
                
                internal init(statement: StatementBasicData, title: String, image: Image?, subtitle: String, amount: Amount?, amountStatusImage: Image?, action: @escaping () -> Void = {}) {
                    
                    self.statement = statement
                    self.title = title
                    self.image = image
                    self.amountStatusImage = amountStatusImage
                    self.subtitle = subtitle
                    self.amount = amount
                    self.action = action
                }
                
                init(statement: ProductStatementData, model: Model, action: @escaping () -> Void) {
                    
                    self.statement = StatementBasicData(statement: statement)
                    self.title = statement.merchant
                    self.image = statement.svgImage?.image
                    self.subtitle = statement.groupName
                    if statement.operationType != .open {
                        
                        let amountFormatted = model.amountFormatted(amount: statement.amount, currencyCodeNumeric: statement.currencyCodeNumeric, style: .normal) ?? "\(statement.amount)"
                        
                        self.amount = .init(value: statement.operationSymbolsAndAmount(amountFormatted), color: statement.operationColor)
                        self.amountStatusImage = statement.image
                        
                    } else {
                        
                        self.amount = nil
                        self.amountStatusImage = nil
                    }
   
                    self.action = action
                }
                
                struct StatementBasicData {
     
                    let id: Int
                    let date: Date
                    let imageId: String
                    
                    internal init(
                        id: Int,
                        date: Date,
                        imageId: String
                    ) {
                        
                        self.id = id
                        self.date = date
                        self.imageId = imageId
                    }
                    
                    init(statement: ProductStatementData) {
                        
                        var hasher = Hasher()
                        hasher.combine(statement.id)
                        hasher.combine(statement.dateValue)
                        hasher.combine(statement.operationType)
                        
                        self.id = hasher.finalize()
                        self.date = statement.dateValue
                        self.imageId = statement.md5hash
                    }
                }
                  
                struct Amount {
                    
                    let value: String
                    let color: Color
                }
            }
        }
    }
}

private extension ProductStatementData {
    
    var operationColor: Color {
        
        switch operationType {
            
        case .credit, .creditPlan: return .systemColorActive
        case .debitFict, .creditFict: return .systemColorError
        default: return .mainColorsBlack
        }
    }
    
    var image: Image? {
        
        switch operationType {
            
        case .debitPlan, .creditPlan: return .ic16Waiting
        case .debitFict, .creditFict: return .ic16Denied
        default: return nil
        }
    }
    
}

//MARK: - View

struct ProductProfileHistoryView: View {
    
    @ObservedObject var viewModel: ProductProfileHistoryView.ViewModel
    let makeHistoryButton: (Bool) -> HistoryButtonView?
    
    var body: some View {
        
        VStack {
            
            HeaderView(
                viewModel: viewModel.header,
                makeHistoryButton: makeHistoryButton(viewModel.segmentBarViewModel != nil)
            )
            .padding(.bottom, 15)
            
            content()
        }
    }
}

private extension ProductProfileHistoryView {

    @ViewBuilder
    func content() -> some View {
        
        switch viewModel.content {
        case let .empty(emptyListViewModel):
            EmptyListView(viewModel: emptyListViewModel)
                .padding(.top, 20)
            
        case let .list(listViewModel):
            segmentedBarView()
                .fixedSize(horizontal: false, vertical: true)
                .border(width: 1, edges: .init(), color: .yellow)

            ListView(viewModel: listViewModel)
                .border(width: 1, edges: .init(), color: .blue)
            
        case .loading:
            LoadingView()
        }
    }
    
    @ViewBuilder
    private func segmentedBarView() -> some View {
        
        viewModel.segmentBarViewModel.map {
            
            SegmentedBarView(viewModel: $0)
                .padding(.vertical, 5)
        }
    }
}

//MARK: - Nested Views

extension ProductProfileHistoryView {
    
    struct HeaderView: View {
        
        let viewModel: ProductProfileHistoryView.ViewModel.HeaderViewModel
        let makeHistoryButton: HistoryButtonView?

        var body: some View {
            
            HStack(alignment: .center) {
                
                Text(viewModel.title)
                    .font(Font.system(size: 22, weight: .bold))
                                
                Spacer()
                
                makeHistoryButton
                
                // temporally off
                /*
                Button(action: viewModel.button.action) {
                    
                    ZStack {
                        
                        Circle()
                            .foregroundColor(.mainColorsGrayLightest)
                        
                        viewModel.button.icon
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.iconBlack)
                    }
                }
                .buttonStyle(PushButtonStyle())
                .frame(width: 32, height: 32)
                 */
            }
        }
    }
    
    struct EmptyListView: View {
        
        let viewModel: ViewModel.EmptyListViewModel
        
        var body: some View {
            
            VStack(spacing: 24) {
                
                ZStack {
                    
                    Circle()
                        .frame(width: 64, height: 64)
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    viewModel.image
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.iconBlack)
                }
                
                //FIXME: set font and color from style guide
                Text(viewModel.title)
                    .font(Font.system(size: 14, weight: .light))
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
    
    struct ListView: View {
        
        @ObservedObject var viewModel: ProductProfileHistoryView.ViewModel.HistoryListViewModel
        
        @ViewBuilder
        private
        func updateView() -> some View {
            
            if let latestUpdate = viewModel.latestUpdate {
                
                switch latestUpdate {
                case .updating:
                    ProductProfileHistoryView.LoadingItemView()
                    
                case .fail(let failViewModel):
                    ProductProfileHistoryView.EldestUpdateFailView(viewModel: failViewModel)
                }
            }
        }
        
        @ViewBuilder
        private
        func eldestUpdateView() -> some View {
            
            if let eldestUpdate = viewModel.eldestUpdate {
                
                switch eldestUpdate {
                case .more(let buttonViewModel):
                    ButtonSimpleView(viewModel: buttonViewModel)
                        .frame(height: 48)
                    
                case .updating:
                    ProductProfileHistoryView.LoadingItemView()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        
        var body: some View {
            
            VStack {
                
                updateView()
                
                ForEach(viewModel.groups) { groupViewModel in
                    
                    ProductProfileHistoryView.GroupView(viewModel: groupViewModel)
                        .background(Color.mainColorsGrayLightest)
                        .cornerRadius(12)
                        .padding(.bottom, 14)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                eldestUpdateView()
            }
        }
    }
    
    struct GroupView: View {
        
        let viewModel: ProductProfileHistoryView.ViewModel.HistoryListViewModel.DayGroupViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(viewModel.title)
                    .font(.textBodyMSb14200())
                    .foregroundColor(.textSecondary)
                    .accessibilityIdentifier("historyGroupDate")
          
                ForEach(viewModel.operations) { operationViewModel in
                    
                    ProductProfileHistoryView.OperationView(viewModel: operationViewModel)
                }
            }
            .padding(.top, 13)
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.bottom, 13)
        }
    }
    
    struct OperationView: View {
        
        @ObservedObject var viewModel: ProductProfileHistoryView.ViewModel.HistoryListViewModel.DayGroupViewModel.Operation
        
        var body: some View {
            
            HStack(alignment: .top, spacing: 20) {
                
                ZStack(alignment: .topTrailing) {
                    
                    if let image = viewModel.image {
                        
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                    } else {
                        
                        Circle()
                            .foregroundColor(.mainColorsGrayMedium)
                            .frame(width: 40, height: 40)
                            .shimmering()
                    }
                   
                    if let image = viewModel.amountStatusImage {
                        image
                            .renderingMode(.original)
                            .frame(width: 16, height: 16)
                            .padding(.trailing, -4)
                    }
                }
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textH4M16240())
                        .foregroundColor(.textSecondary)
                        .accessibilityIdentifier("operationName")
                    
                    Text(viewModel.subtitle)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                        .accessibilityIdentifier("operationDescription")
                }
                .padding(.vertical, 8)
                
                Spacer()
                
                if let amount = viewModel.amount {
                    
                    Text(amount.value)
                        .font(.textH4M16240())
                        .foregroundColor(amount.color)
                        .padding(.top, 8)
                        .accessibilityIdentifier("operationAmount")
                }
            }
            .onTapGesture {
            
                viewModel.action()
            }
        }
    }
    
    struct LoadingView: View {
        
        var body: some View {
            
            VStack(spacing: 20){
                
                ForEach(0..<3) { _ in
                    
                    ProductProfileHistoryView.LoadingItemView()
                }
            }
        }
    }
    
    struct LoadingItemView: View {
        
        let color = Color.mainColorsGrayMedium
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 20) {
                
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(color)
                    .frame(width: 189, height: 20)
                    
                HStack(spacing: 15) {
                    
                    Circle()
                        .foregroundColor(color)
                        .frame(width: 40, height: 40)
                    
                    VStack(spacing: 8) {
                        
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(color)
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(color)
                            .frame(height: 12)
                    }
                    .padding(.leading, 5)
                    
                    VStack {
                        
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundColor(color)
                            .frame(width: 72, height: 20)
                    }
                }
                .padding(.vertical, 8)
                .frame(height: 56)
            }
            .shimmering()
            .frame(height: 112)
            .clipped()
        }
    }
    
    struct EldestUpdateFailView: View {
        
        let viewModel: ProductProfileHistoryView.ViewModel.HistoryListViewModel.LatestUpdateState.FailViewModel
        
        var body: some View {
            
            
            HStack(alignment: .top, spacing: 20) {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.systemColorWarning)
                        .frame(width: 40, height: 40)
                    
                    Image.ic24AlertOctagon
                        .renderingMode(.template)
                        .foregroundColor(.textWhite)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textH4M16240())
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                    
                    Text(viewModel.subtitle)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                }
                
                Spacer()
            }
        }
    }
}

//MARK: - Preview

struct HistoryViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            ProductProfileHistoryView(
                viewModel: .sample,
                makeHistoryButton: { _ in .init(event: { event in }, isFiltered: { true }, isDateFiltered: { true }, clearOptions: {})}
            )
            .previewLayout(.fixed(width: 375, height: 500))
            
            ProductProfileHistoryView(
                viewModel: .sampleSecond,
                makeHistoryButton: { _ in .init(event: { event in }, isFiltered: { true }, isDateFiltered: { true }, clearOptions: {})}
            )
            .previewLayout(.fixed(width: 375, height: 400))
            
            ProductProfileHistoryView.EmptyListView(
                viewModel: .init()
            )
            .previewLayout(.fixed(width: 375, height: 300))
            
            ProductProfileHistoryView.LoadingView()
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 400))
            
            ProductProfileHistoryView.EldestUpdateFailView(viewModel: .sample)
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 80))
            
            ProductProfileHistoryView.LoadingItemView()
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 120))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileHistoryView.ViewModel.HistoryListViewModel.DayGroupViewModel {
    
    static let debitOperation = Operation(statement: .init(id: 0, date: Date(), imageId: ""), title: "Плата за обслуживание", image: Image("MigAvatar"), subtitle: "Услуги банка", amount: .init(value: "-65 Р", color: .black), amountStatusImage: Image("MigAvatar"))
    
    static let creditOperation = Operation(statement: .init(id: 1, date: Date(), imageId: ""), title: "Оплата банка", image: Image.init("foraContactImage"), subtitle: "Услуги банка", amount: .init(value: "-100 Р", color: .black), amountStatusImage: Image("MigAvatar"))
}

extension ProductProfileHistoryView.ViewModel.HistoryListViewModel.LatestUpdateState.FailViewModel {
    
    static let sample = ProductProfileHistoryView.ViewModel.HistoryListViewModel.LatestUpdateState.FailViewModel(title: "Ошибка! Попробуйте позже.", subtitle: "Отражены данные на ...")
}

extension ProductProfileHistoryView.ViewModel {
    
    static let sample = ProductProfileHistoryView.ViewModel(productId: 1, state: .list(.init(expences: nil, latestUpdate: nil, groups: [.init(id: 0, title: "25 августа, ср", operations: [.init(statement: .init(id: 0, date: Date(), imageId: ""), title: "Плата за обслуживание за октябрь 2021", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 65 Р", color: .black), amountStatusImage: Image("MigAvatar")), .init(statement: .init(id: 1, date: Date(), imageId: ""), title: "Selhozmarket", image: Image.init("GKH", bundle: nil), subtitle: "Магазин", amount: .init(value: "- 230 Р", color: .black), amountStatusImage: Image("MigAvatar"))]), .init(id: 1, title: "26 августа, ср", operations: [.init(statement: .init(id: 2, date: Date(), imageId: ""), title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 100 Р", color: .black), amountStatusImage: Image("MigAvatar"))])], eldestUpdate: nil)), filter: { nil })
    
    static let sampleSecond = ProductProfileHistoryView.ViewModel(productId: 2, state: .list(.init(expences: nil, latestUpdate: nil, groups: [.init(id: 0, title: "25 августа, ср", operations: [.init(statement: .init(id: 0, date: Date(), imageId: ""), title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 65 Р", color: .black), amountStatusImage: Image("MigAvatar"))]), .init(id: 1, title: "26 августа, ср", operations: [.init(statement: .init(id: 1, date: Date(), imageId: ""), title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 100 Р", color: .black), amountStatusImage: Image("MigAvatar"))])], eldestUpdate: .more(.init(title: "Смотреть еще", style: .gray, action: {}))) ), filter: { nil })
    
    static let sampleHistory = ProductProfileHistoryView.ViewModel(productId: 3, state: .list(.init(expences: nil, latestUpdate: nil, groups: [.init(id: 0, title: "12 декабря", operations: [.init(statement: .init(id: 0, date: Date(), imageId: ""), title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 100 Р", color: .black), amountStatusImage: Image("MigAvatar")), .init(statement: .init(id: 1, date: Date(), imageId: ""), title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 100 Р", color: .black), amountStatusImage: Image("MigAvatar")), .init(statement: .init(id: 2, date: Date(), imageId: ""), title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 100 Р", color: .black), amountStatusImage: Image("MigAvatar")), .init(statement: .init(id: 3, date: Date(), imageId: ""), title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 100 Р", color: .black), amountStatusImage: Image("MigAvatar")), .init(statement: .init(id: 4, date: Date(), imageId: ""), title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: .init(value: "- 100 Р", color: .black), amountStatusImage: Image("MigAvatar"))])], eldestUpdate: nil)), filter: { nil })
}
