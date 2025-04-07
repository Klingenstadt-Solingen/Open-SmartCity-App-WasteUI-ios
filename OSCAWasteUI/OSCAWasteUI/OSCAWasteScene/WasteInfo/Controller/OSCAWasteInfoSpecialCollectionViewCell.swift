//
//  OSCAWasteInfoSpecialCollectionViewCell.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 01.03.23.
//

import OSCAEssentials
import UIKit

public final class OSCAWasteInfoSpecialCollectionViewCell: UICollectionViewCell {
  public static let identifier = String(describing: OSCAWasteInfoSpecialCollectionViewCell.self)
  
  @IBOutlet private var imageContainer: UIView!
  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var titleLabel: UILabel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.contentView.backgroundColor = .clear
    
    self.imageContainer.addShadow(with: OSCAWasteUI.configuration.shadow)
    self.imageContainer.layer.cornerRadius = self.imageContainer.frame.height / 2
    
    self.titleLabel.font = OSCAWasteUI.configuration.fontConfig.smallLight
    self.titleLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    self.titleLabel.numberOfLines = 2
  }
  
  func fill(with viewModel: OSCAWasteInfoSpecialCellViewModel) {
    let backgroundColor = (UIColor(hex: viewModel.imageColor) ?? OSCAWasteUI.configuration.colorConfig.whiteColor).withAlphaComponent(0.75)
    
    self.imageContainer.backgroundColor = backgroundColor
    
    let image = UIImage(named: viewModel.imageName,
                        in: OSCAWasteUI.bundle,
                        with: .none)
    image?.withRenderingMode(.alwaysTemplate)
    self.imageView.image = image
    let imageTintColor = backgroundColor.isDarkColor
      ? OSCAWasteUI.configuration.colorConfig.whiteColor.withAlphaComponent(0.75)
      : OSCAWasteUI.configuration.colorConfig.blackColor.withAlphaComponent(0.75)
    self.imageView.tintColor = imageTintColor
    
    self.titleLabel.text = viewModel.title
    viewModel.fill()
  }
}
