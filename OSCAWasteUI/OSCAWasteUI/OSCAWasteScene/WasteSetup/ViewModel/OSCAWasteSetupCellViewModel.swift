//
//  OSCAWasteSetupCellViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 12.07.22.
//

import OSCAWaste
import Foundation

public final class OSCAWasteSetupCellViewModel {
  
  let wasteAddress: OSCAWasteAddress
  
  // MARK: Initializer
  public init(wasteAddress: OSCAWasteAddress) {
    self.wasteAddress = wasteAddress
  }
  
  // MARK: - OUTPUT
  
  var wasteFullStreetAddress: String {
    return wasteAddress.fullAddress ?? ""
  }
}

// MARK: - INPUT. View event methods
extension OSCAWasteSetupCellViewModel {
  func fill() {}
}
