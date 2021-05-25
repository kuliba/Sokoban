

import Foundation
import FSPagerView

protocol ICellConfigurator: NSObject {
    static var reuseId: String { get }

    var currentBlock: Bool? { get set }
    var currentValueBlock: Bool? { get set }
    var delegate: ICellConfiguratorDelegate? { get set }
    func configure(cell: UIView)
}

protocol ICellConfiguratorDelegate: class {
    func didReciveNewValue(value: Any, from configurator: ICellConfigurator)
}

class PagerViewCellHandler<CellType: IConfigurableCell, ProviderType: ICellProvider>: NSObject, ICellConfigurator where CellType.ICellProvider == ICellProvider, CellType: FSPagerViewCell {
    var currentBlock: Bool?
    
    
     var currentValueBlock: Bool?

    static var reuseId: String { return String(describing: CellType.self) }

    let provider: ICellProvider

    weak var delegate: ICellConfiguratorDelegate?

    
    init(provider: ICellProvider, delegate: ICellConfiguratorDelegate) {
        self.provider = provider
        self.delegate = delegate
    }

    func configure(cell: UIView) {
        guard let cell = cell as? CellType else { return }
        cell.configure(provider: provider, delegate: self)
    }
}

extension PagerViewCellHandler: ConfigurableCellDelegate {
    func didInputPaymentValue(value: Any) {
        delegate?.didReciveNewValue(value: value, from: self)
        
    }
}
