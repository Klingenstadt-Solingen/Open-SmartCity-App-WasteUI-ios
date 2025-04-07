//
//  OSCAWasteInfoViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 04.07.22.
//

import OSCANetworkService
import OSCAWaste
import Foundation
import Combine

public struct OSCAWasteInfoViewModelActions {
  let showWasteDescription: (OSCAWasteType, OSCAWasteInfo?, OSCAWasteSubtype?, OSCAWasteLocation?) -> Void
}

public final class OSCAWasteInfoViewModel {
  
  let dataCache = NSCache<NSString, NSData>()
  let dataModule: OSCAWaste
  private let actions: OSCAWasteInfoViewModelActions?
  let wasteType: OSCAWasteType
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  public init(dataModule: OSCAWaste,
              actions: OSCAWasteInfoViewModelActions,
              wasteType: OSCAWasteType) {
    self.dataModule = dataModule
    self.actions = actions
    self.wasteType = wasteType
  }
  
  // MARK: - OUTPUT
  
  enum Section {
    case wasteInfo
    case wasteType
  }
  
  @Published var wasteInfos: [OSCAWasteInfo] = []
  @Published var wasteSpecialSubtypes: [OSCAWasteSubtype] = []
  
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
  
  var wasteDescription: String {
    wasteType == .pickedUp ? pickedUpWasteInfo : specialWasteInfo
  }
  
  var wasteLocations: [OSCAWasteLocation]? = nil
  
  // MARK: Localized Strings
  
  var screenTitle: String { NSLocalizedString(
    "waste_info_screen_title",
    bundle: self.bundle,
    comment: "The screen title") }
  var pickedUpWasteInfo: String { NSLocalizedString(
    "waste_picked_up_waste_info",
    bundle: self.bundle,
    comment: "The information about picked up waste") }
  var specialWasteInfo: String { NSLocalizedString(
    "waste_special_waste_info",
    bundle: self.bundle,
    comment: "The information about special waste") }
  
  // MARK: - Private
  
  private func getWasteInfos() {
    self.dataModule.fetchWasteInfos(for: "de_DE")
      .sink { completion in
        switch completion {
        case .finished:
          print(".finished \(#function)")
          
        case .failure:
          print(".failure \(#function)")
        }
        
      } receiveValue: { wasteInfos in
        self.wasteInfos = wasteInfos
        
      }
      .store(in: &self.bindings)
  }
  
  private func fetchAllWasteLocations() {
    self.dataModule.fetchAllWasteLocations()
      .sink { completion in
        switch completion {
        case .finished:
          print(".finished getWasteLocations()")
          
        case .failure:
          print(".failure getWasteLocation()")
        }
        
      } receiveValue: { wasteLocations in
        self.wasteLocations = wasteLocations
        
        var wasteSubtypes: [OSCAWasteSubtype] = []
        for wasteLocation in wasteLocations {
          if let type = wasteLocation.wasteType {
            switch type {
            case .electricalWaste:
              wasteSubtypes.append(OSCAWasteSubtype(type: type, imageName: type.rawValue, imageColor: "#73FCD6"))
            case .greenWaste:
              wasteSubtypes.append(OSCAWasteSubtype(type: type, imageName: type.rawValue, imageColor: "#73FA79"))
            case .disposalYard:
              wasteSubtypes.append(OSCAWasteSubtype(type: type, imageName: type.rawValue, imageColor: "#00F900"))
            case .wasteToEnergy:
              wasteSubtypes.append(OSCAWasteSubtype(type: type, imageName: type.rawValue, imageColor: "#008F00"))
            default: continue
            }
          }
        }
        
        self.wasteSpecialSubtypes = wasteSubtypes
      }
      .store(in: &bindings)
  }
}

// MARK: - Input, view event methods
extension OSCAWasteInfoViewModel {
  func viewDidLoad() {
    if self.wasteType == .pickedUp {
      self.getWasteInfos()
      
    } else {
      self.fetchAllWasteLocations()
    }
  }
  
  func didSelect(at index: Int) {
    switch wasteType {
    case .pickedUp:
      let wasteInfo = self.wasteInfos[index]
      actions?.showWasteDescription(wasteType, wasteInfo, nil, nil)
      
    case .special:
      if let specialWasteSubtypes = wasteLocations {
        actions?.showWasteDescription(wasteType, nil, nil, specialWasteSubtypes[index])
      }
    }
  }
}
