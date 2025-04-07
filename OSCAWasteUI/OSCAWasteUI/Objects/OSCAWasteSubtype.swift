//
//  OSCAWasteSubtype.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 05.07.22.
//

import OSCAWaste
import Foundation

public struct OSCAWasteSubtype: Hashable, Equatable {
  public var type: OSCAWasteBinType
  public var imageName: String
  public var imageColor: String
  
  public init(type: OSCAWasteBinType, imageName: String, imageColor: String) {
    self.type = type
    self.imageName = imageName
    self.imageColor = imageColor
  }
  
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
  
  public var description: String {
    switch type {
    case .organicWaste:
      return NSLocalizedString("waste_organic_waste_description",
                               bundle: self.bundle,
                               comment: "The description for organic waste")
    case .residualWaste:
      return NSLocalizedString("waste_residual_waste_description",
                               bundle: self.bundle,
                               comment: "The description for residual waste")
    case .recycledPaper:
      return NSLocalizedString("waste_recycled_paper_description",
                               bundle: self.bundle,
                               comment: "The description for recycled paper")
    case .dualSystem:
      return NSLocalizedString("waste_dual_system_description",
                               bundle: self.bundle,
                               comment: "The description for dual system")
    case .christmasTree:
      return NSLocalizedString("waste_christmas_tree_description",
                               bundle: self.bundle,
                               comment: "The description for christmas tree")
    case .bulkWaste:
      return NSLocalizedString("waste_bulk_waste_description",
                               bundle: self.bundle,
                               comment: "The description for bulk waste")
    default: return ""
    }
  }
}
