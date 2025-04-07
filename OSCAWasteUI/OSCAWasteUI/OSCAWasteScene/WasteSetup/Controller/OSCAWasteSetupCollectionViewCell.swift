//
//  OSCAWasteSetupCollectionViewCell.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 12.07.22.
//

import OSCAEssentials
import UIKit

public final class OSCAWasteSetupCollectionViewCell: UICollectionViewCell {
  public static let identifier = String(describing: OSCAWasteSetupCollectionViewCell.self)
  
  @IBOutlet private var titleLabel: UILabel!
  
  private var viewModel: OSCAWasteSetupCellViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.tintColor = OSCAWasteUI.configuration.colorConfig.primaryColor
    self.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    let backgroundView = UIView()
    backgroundView.backgroundColor = OSCAWasteUI.configuration.colorConfig.primaryColor.withAlphaComponent(0.5)
    selectedBackgroundView = backgroundView
    selectedBackgroundView?.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    
    self.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    self.addShadow(with: OSCAWasteUI.configuration.shadow)
    
    self.titleLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    self.titleLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    self.titleLabel.numberOfLines = 0
  }
  
  func fill(with viewModel: OSCAWasteSetupCellViewModel) {
    self.viewModel = viewModel
    
    self.titleLabel.text = viewModel.wasteFullStreetAddress
    
    viewModel.fill()
  }
}
