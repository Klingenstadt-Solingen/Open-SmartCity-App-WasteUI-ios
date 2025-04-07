//
//  OSCAWasteAppointmentCellViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 24.06.22.
//

import OSCAWaste
import Foundation
import Combine

public final class OSCAWasteAppointmentCellViewModel {
  
  private var bindings = Set<AnyCancellable>()
  let dataCache: NSCache<NSString, NSData>
  
  let wasteCollect: OSCAWasteCollect
  let dataModule: OSCAWaste
  
  @Published private(set) var imageData: Data? = nil
  
  // MARK: Initializer
  public init(dataModule: OSCAWaste, dataCache: NSCache<NSString, NSData>,  wasteCollect: OSCAWasteCollect) {
    self.dataModule = dataModule
    self.wasteCollect = wasteCollect
    self.dataCache = dataCache
    self.fetchImage()
  }
  
  // MARK: - OUTPUT
  
  var title: String {
    let dateFormat = "EE, d. MMMM yyyy"
    
    guard let date = wasteCollect.date else { return "---" }
    let dateString = Date.dateFromISOString(string: date)
      .localFormatTime(custom: dateFormat)
    
    return dateString
  }
  
  var binType : OSCAWasteCollectBinType {
    if let binId = self.wasteCollect.type, let binName = self.wasteCollect.name {
      return OSCAWasteCollectBinType.with(id: binId, name: binName)
    }
    return OSCAWasteCollectBinType.fromStaticTypeId(id: self.wasteCollect.type)
  }
  
    var subtitle: String {
        if let name = wasteCollect.name {
            if let time = wasteCollect.time {
                "\(name)\n\(time)"
            } else {
                name
            }
        } else if let binType = wasteCollect.binType, let binTypeName = binType.name {
            binTypeName
        } else if let binTypeName = binType.name {
            binTypeName
        } else {
            ""
        }
    }
  
  var wasteColor: String? { wasteCollect.color }
  var wasteIconUrl: String? { wasteCollect.icon }
}

// MARK: - INPUT. View event methods
extension OSCAWasteAppointmentCellViewModel {
  func fill() {
    if self.imageData == nil {
      self.fetchImage()
    }
  }
}


extension OSCAWasteAppointmentCellViewModel {
  private func fetchImage() {
    guard var http = self.wasteIconUrl else { return }
    
    if http.last == "/" {
      http.removeLast()
    }
    
    guard let url = URL(string: http) else { return }
    
    self.dataModule.fetchImageData(from: url)
    .sink { completion in
      switch completion {
      case .finished:
        print("\(Self.self): finished \(#function)")
        
      case .failure:
        print("\(Self.self): .sink: failure \(#function)")
      }
      
    } receiveValue: { fetchedImage in
      self.imageData = fetchedImage
      guard let iconUrl = self.wasteIconUrl else { return }
      
      self.dataCache.setObject(
        NSData(data: fetchedImage),
        forKey: iconUrl as NSString)
    }
    .store(in: &self.bindings)
  }
}
