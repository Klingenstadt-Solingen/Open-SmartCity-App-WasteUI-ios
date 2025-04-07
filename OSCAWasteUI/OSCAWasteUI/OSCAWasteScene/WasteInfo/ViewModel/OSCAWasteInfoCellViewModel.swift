//
//  OSCAWasteInfoCellViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 05.07.22.
//

import OSCAWaste
import Foundation
import Combine

public final class OSCAWasteInfoCellViewModel {
  
  let dataCache: NSCache<NSString, NSData>
  let dataModule: OSCAWaste
  let wasteInfo: OSCAWasteInfo
  
  // MARK: Initializer
  public init(dataModule: OSCAWaste, dataCache: NSCache<NSString, NSData>, wasteInfo: OSCAWasteInfo) {
    self.dataModule = dataModule
    self.dataCache = dataCache
    self.wasteInfo = wasteInfo
  }
  
  private var bindings = Set<AnyCancellable>()
  
  // MARK: - OUTPUT
  
  @Published private(set) var imageData: Data? = nil
  
  var imageDataFromCache: Data? {
    guard let iconUrl = self.iconUrl
    else { return nil }
    let imageData = self.dataCache
      .object(forKey: iconUrl as NSString)
    return imageData as? Data
  }
  
  var iconUrl: String? {
    guard let http = self.wasteInfo.icon
    else { return nil }
    return http
  }
  var color: String { self.wasteInfo.color ?? "#000000" }
  var title: String { self.wasteInfo.title ?? "" }
}

// MARK: - Data access
extension OSCAWasteInfoCellViewModel {
  private func fetchImage() {
    guard var http = self.iconUrl
    else { return }
    
    if http.last == "/" {
      http.removeLast()
    }
    
    guard let url = URL(string: http)
    else { return }
    
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
      
      guard let iconUrl = self.iconUrl
      else { return }
      
      self.dataCache.setObject(
        NSData(data: fetchedImage),
        forKey: iconUrl as NSString)
    }
    .store(in: &self.bindings)
  }
}

// MARK: - INPUT. View event methods
extension OSCAWasteInfoCellViewModel {
  func fill() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if self.imageDataFromCache == nil {
      self.fetchImage()
      
    } else {
      self.imageData = self.imageDataFromCache
    }
  }
}
