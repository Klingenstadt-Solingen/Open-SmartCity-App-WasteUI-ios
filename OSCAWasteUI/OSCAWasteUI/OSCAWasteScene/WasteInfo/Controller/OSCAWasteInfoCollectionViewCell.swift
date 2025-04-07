//
//  OSCAWasteInfoCollectionViewCell.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 05.07.22.
//

import OSCAEssentials
import UIKit
import Combine

public final class OSCAWasteInfoCollectionViewCell: UICollectionViewCell {
  public static let identifier = String(describing: OSCAWasteInfoCollectionViewCell.self)
  
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
  
  private var viewModel: OSCAWasteInfoCellViewModel!
  private var bindings = Set<AnyCancellable>()
  
  func fill(with viewModel: OSCAWasteInfoCellViewModel) {
    self.viewModel = viewModel
    
    let backgroundColor = (UIColor(hex: viewModel.color) ?? OSCAWasteUI.configuration.colorConfig.whiteColor).withAlphaComponent(0.75)
    
    self.imageContainer.backgroundColor = backgroundColor
    
    if let imageData = viewModel.imageDataFromCache {
      let image = UIImage(data: imageData)
      image?.withRenderingMode(.alwaysTemplate)
      self.imageView.contentMode = .scaleAspectFill
      self.imageView.image = UIImage(data: imageData)
      
    }
    
    let imageTintColor = backgroundColor.isDarkColor
      ? OSCAWasteUI.configuration.colorConfig.whiteColor.withAlphaComponent(0.75)
      : OSCAWasteUI.configuration.colorConfig.blackColor.withAlphaComponent(0.75)
    self.imageView.tintColor = imageTintColor
    
    self.titleLabel.text = viewModel.title
    
    self.setupBindings()
    viewModel.fill()
  }
  
  private func setupBindings() {
    self.viewModel.$imageData
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] imageData in
        guard let `self` = self,
              let imageData = imageData
        else { return }
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = UIImage(data: imageData)
      })
      .store(in: &self.bindings)
  }
}
