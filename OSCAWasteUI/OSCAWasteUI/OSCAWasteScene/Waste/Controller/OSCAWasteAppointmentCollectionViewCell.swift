//
//  OSCAWasteAppointmentCollectionViewCell.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 24.06.22.
//

import OSCAEssentials
import OSCAWaste
import UIKit
import Combine

public final class OSCAWasteAppointmentCollectionViewCell: UICollectionViewCell {
  public static let identifier = String(describing: OSCAWasteAppointmentCollectionViewCell.self)
  private var bindings = Set<AnyCancellable>()
  
  @IBOutlet private var leftImageView: UIImageView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var subtitleLabel: UILabel!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    self.contentView.backgroundColor = OSCAWasteUI.configuration.colorConfig.secondaryBackgroundColor
    self.contentView.layer.cornerRadius = OSCAWasteUI.configuration.cornerRadius
    
    self.addShadow(with: OSCAWasteUI.configuration.shadow)
    
    self.titleLabel.font = OSCAWasteUI.configuration.fontConfig.bodyLight
    self.subtitleLabel.font = OSCAWasteUI.configuration.fontConfig.bodyHeavy
    
    self.titleLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    self.subtitleLabel.textColor = OSCAWasteUI.configuration.colorConfig.textColor
    
    self.titleLabel.numberOfLines = 1
    self.subtitleLabel.numberOfLines = 2
  }
  
  func fill(with viewModel: OSCAWasteAppointmentCellViewModel) {
    self.layoutIfNeeded()
    
    self.titleLabel.text = viewModel.title
    self.subtitleLabel.text = viewModel.subtitle
    
    let colorConfig = OSCAWasteUI.configuration.colorConfig
    
    self.leftImageView.layer.cornerRadius = self.leftImageView.frame.width / 2
    
    self.leftImageView.contentMode = .scaleAspectFill
    
    if let imageData = viewModel.imageData {
      self.leftImageView.image = UIImage(data: imageData)
    } else {
      setupBindings(viewModel: viewModel)
    }
  }
  
  public func setColor(hex: String?, showBorder: Bool = false) {
    guard let hex = hex,
          let collectionColor = UIColor(hex: hex)
    else {
      self.leftImageView.backgroundColor = .clear
      return
    }

    self.leftImageView.backgroundColor = collectionColor

    if showBorder {
      self.leftImageView.layer.borderWidth = 1.0
      self.leftImageView.layer.borderColor = collectionColor.cgColor
    }
  }
  
  public func updateImage(with imageData: Data) {
    self.leftImageView.contentMode = .scaleAspectFill
    self.leftImageView.image = UIImage(data: imageData)
  }
  
  private func setupBindings(viewModel: OSCAWasteAppointmentCellViewModel) {
      
    viewModel.$imageData
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] imageData in
        guard let `self` = self,
              let imageData = imageData
        else { return }
        DispatchQueue.main.async {
          self.updateImage(with: imageData)
        }
      })
      .store(in: &self.bindings)
  }
  
}
