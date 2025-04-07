//
//  OSCAWasteAppointmentViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 24.06.22.
//

import OSCAWaste
import Foundation
import Combine

public final class OSCAWasteAppointmentViewModel {
  let dataModule: OSCAWaste
  let dataCache: NSCache<NSString, NSData>
  
  var appointmentViewModels: [OSCAWasteAppointmentCellViewModel] = []
  
  let wasteCollectsAtAddress: OSCAWasteCollectsAtAddress
  
  let selectedBinTypes: [Int]
  
  // MARK: Initializer
  public init(dataModule: OSCAWaste, dataCache: NSCache<NSString, NSData>, wasteCollectsAtAddress: OSCAWasteCollectsAtAddress, binTypes: [Int]) {
    self.dataModule = dataModule
    self.dataCache = dataCache
    self.wasteCollectsAtAddress = wasteCollectsAtAddress
    self.selectedBinTypes = binTypes
    
    self.appointmentViewModels = wasteCollectsAtAddress.collection?.compactMap { collection in
      OSCAWasteAppointmentCellViewModel(
        dataModule: self.dataModule,
        dataCache: self.dataCache,
        wasteCollect: collection)
    } ?? []
  }
  
  // MARK: - OUTPUT
  
  enum Section { case wasteAppointment }
  
  var screenTitle: String { wasteCollectsAtAddress.address ?? "" }
  
  var collections: [OSCAWasteCollect] {
    guard let collections = wasteCollectsAtAddress.collection else { return [] }
    
    return collections.filter {
      $0.type != nil && (self.selectedBinTypes.isEmpty || selectedBinTypes.contains($0.type!))
    }
  }
  
  
  var sortedCollections: [OSCAWasteCollect] {
    var collections: [OSCAWasteCollect] = []
    guard let allCollection = wasteCollectsAtAddress.collection else { return [] }
    
    for collection in allCollection {
      guard let dateString = collection.date,
            let isoDate = Date.dateFromISOString(string: dateString)
      else { return [] }
      
      let now = Date()
      let wasteDate = isoDate
      
      if wasteDate.isAfterDate(now, orEqual: true, granularity: .weekdayOrdinal) {
        collections.append(collection)
      }
    }
    
    return collections.sorted(by: {
      guard let firstString = $0.date,
            let secondString = $1.date,
            let firstDate = Date.dateFromISOString(string: firstString),
            let secondDate = Date.dateFromISOString(string: secondString)
      else { return false }
      return firstDate < secondDate
    })
  }
}

// MARK: - Input, view event methods
extension OSCAWasteAppointmentViewModel {
  func viewDidLoad() {}
}
