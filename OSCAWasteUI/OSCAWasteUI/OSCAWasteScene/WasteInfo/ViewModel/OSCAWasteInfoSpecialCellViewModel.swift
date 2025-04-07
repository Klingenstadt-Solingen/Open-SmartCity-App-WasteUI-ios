//
//  OSCAWasteInfoSpecialCellViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 01.03.23.
//

import OSCAWaste
import Foundation

public final class OSCAWasteInfoSpecialCellViewModel {
  
  let wasteSubtype: OSCAWasteSubtype
  
  // MARK: Initializer
  public init(wasteSubtype: OSCAWasteSubtype) {
    self.wasteSubtype = wasteSubtype
  }
  
  // MARK: - OUTPUT
  
  var imageName: String { wasteSubtype.imageName }
  var imageColor: String { wasteSubtype.imageColor }
  var title: String { wasteSubtype.type.localizedString() }
}

// MARK: - INPUT. View event methods
extension OSCAWasteInfoSpecialCellViewModel {
  func fill() {}
}
