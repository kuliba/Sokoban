

import Foundation

protocol IConfigurableCell: class {
    associatedtype ICellProvider

    var delegate: ConfigurableCellDelegate? { get set }
    func configure(provider: ICellProvider, delegate: ConfigurableCellDelegate)
}

protocol ConfigurableCellDelegate: class {
    func didInputPaymentValue(value: Any)
}
