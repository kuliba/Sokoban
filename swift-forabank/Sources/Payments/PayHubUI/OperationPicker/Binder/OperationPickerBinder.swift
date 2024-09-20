//
//  OperationPickerBinder.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub

public typealias OperationPickerBinder<Exchange, Latest, LatestFlow, Status, Templates> = Binder<OperationPickerContent<Latest>, OperationPickerFlow<Exchange, Latest, LatestFlow, Status, Templates>>
