//
//  OSCAWasteSetupReusableViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 13.07.22.
//

import Foundation

public final class OSCAWasteSetupReusableViewModel {
  
  // MARK: Initializer
  public init() {}
  
  // MARK: - OUTPUT
  
  /**
   Use this to get access to the __Bundle__ delivered from this module's configuration parameter __externalBundle__.
   - Returns: The __Bundle__ given to this module's configuration parameter __externalBundle__. If __externalBundle__ is __nil__, The module's own __Bundle__ is returned instead.
   */
  var bundle: Bundle = {
    if let bundle = OSCAWasteUI.configuration.externalBundle {
      return bundle
    }
    else { return OSCAWasteUI.bundle }
  }()
  
  var addressSetupInstruction: String { NSLocalizedString(
    "waste_address_setup_instruction",
    bundle: self.bundle,
    comment: "The instruction for setting up the user waste address") }
}

// MARK: - INPUT. View event methods
extension OSCAWasteSetupReusableViewModel {
  func fill() {}
}
