//
//  OSCAWasteSetupCollectionReusableView.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 13.07.22.
//

import OSCAEssentials
import UIKit

public final class OSCAWasteSetupCollectionReusableView: UICollectionReusableView {
  public static let identifier = String(describing: OSCAWasteSetupCollectionReusableView.self)
        
  @IBOutlet weak var titleLabel: UILabel!
  
  private var viewModel: OSCAWasteSetupReusableViewModel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.titleLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    self.titleLabel.textColor = OSCAWasteUI.configuration.colorConfig.whiteColor.darker(componentDelta: 0.5)
    self.titleLabel.numberOfLines = 0
  }
  
  
  func fill(with viewModel: OSCAWasteSetupReusableViewModel) {
    self.viewModel = viewModel
    
    self.titleLabel.text = viewModel.addressSetupInstruction
    
    viewModel.fill()
  }
}
