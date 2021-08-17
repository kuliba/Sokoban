//
//  GKHAnyCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.08.2021.
//

import UIKit

final class GKHAnyCell: UITableViewCell, AdaptedCellProtocol {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet weak var organizationImage: UIImageView!
    @IBOutlet weak var taxtField: UITextField!
    @IBOutlet weak var titleLable: UILabel!
    
    // MARK: - Public properties
    
    var viewModel: GKHAnyCellInputProtocol? {
        didSet {
            bindViewModel()
        }
    }
    
    // MARK: - Private methods
    
    private func bindViewModel() {
        label.text = viewModel?.lable
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .white
    }

}
