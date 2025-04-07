//
//  OSCAWasteAppointmentViewModelWidget.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 21.03.23.
//

import OSCAEssentials
import OSCAWaste
import Foundation
import Combine


public final class OSCAWasteAppointmentViewModelWidget {
  
  let dependencies: OSCAWasteAppointmentViewModelWidget.Dependencies
  private let actions: OSCAWasteAppointmentViewModelWidget.Actions
  public let dataModule: OSCAWaste
  let moduleConfig: OSCAWasteUI.Config
  let numberOfVisibleItems: Int
  
  init(dependencies: OSCAWasteAppointmentViewModelWidget.Dependencies) {
#if DEBUG
    print("\(Self.self): \(#function)")
#endif
    self.dependencies         = dependencies
    self.actions              = dependencies.actions
    self.dataModule           = dependencies.dataModule
    self.moduleConfig         = dependencies.moduleConfig
    self.numberOfVisibleItems = dependencies.moduleConfig
      .numberOfAppointments
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(filtersDidChange(notification:)),
      name: .userWasteFiltersDidChange,
      object: nil)
  }
  
  private var bindings = Set<AnyCancellable>()
  
  // MARK: - OUTPUT
  
  @Published private(set) var state: OSCAWasteAppointmentViewModelWidget.State = .loading
  @Published var wasteCollects: [OSCAWasteCollect] = []
  
  /**
   Use this to get access to the __Bundle__ delivered from this module's configuration parameter __externalBundle__.
   - Returns: The __Bundle__ given to this module's configuration parameter __externalBundle__. If __externalBundle__ is __nil__, The module's own __Bundle__ is returned instead.
   */
  lazy var bundle: Bundle = {
    if let bundle = OSCAWasteUI.configuration.externalBundle {
      return bundle
    }
    else { return OSCAWasteUI.bundle }
  }()
  
  var noAppointmentsText: String {
    NSLocalizedString(
      "waste_widget_no_appointments",
      bundle: OSCAWasteUI.bundle,
      comment: "Message when appointment list is empty ")
  }
}

// MARK: - View Model dependencies
extension OSCAWasteAppointmentViewModelWidget {
  public struct Dependencies {
    var actions     : OSCAWasteAppointmentViewModelWidget.Actions
    var dataModule  : OSCAWaste
    var moduleConfig: OSCAWasteUI.Config
    var dataCache: NSCache<NSString, NSData>
  }
}

// MARK: - Sections
extension OSCAWasteAppointmentViewModelWidget {
  public enum Section {
    case wasteAppointment
  }
}

// MARK: - Actions
extension OSCAWasteAppointmentViewModelWidget {
  public struct Actions {}
}

// MARK: - States
extension OSCAWasteAppointmentViewModelWidget {
  public enum State: Equatable {
    case loading
    case finishedLoading
    case error(OSCAWasteAppointmentViewModelWidget.Error)
  }
}

// MARK: - Error
extension OSCAWasteAppointmentViewModelWidget {
  public enum Error: Swift.Error {
    case wasteAddress
    case wasteCollectFetch
  }
}

// MARK: - Data access
extension OSCAWasteAppointmentViewModelWidget {
  @objc private func fetchWasteCollects() {
    self.state = .loading
    
    guard let wasteAddress = try? self.dataModule.userDefaults
      .getOSCAWasteAddress()
    else {
      self.dataModule.userDefaults.setOSCAWasteReminder(false)
      return
    }
    
    let selectedBinTypes = self.dataModule.userDefaults.getOSCAWasteSelectedBinTypeIds()
    
    self.dataModule.fetchWasteCollections(for: wasteAddress, binTypes: selectedBinTypes)
      .sink { completion in
        switch completion {
        case .finished:
#if DEBUG
          print("\(String(describing: self)): .finished \(#function)")
#endif
          self.state = .finishedLoading
          
        case let .failure(error):
#if DEBUG
          print("\(String(describing: self)): .failure \(#function)")
#endif
          print(error)
          self.state = .error(.wasteCollectFetch)
        }
        
      } receiveValue: { fetchedWasteCollectsAtAddress in
        guard let fetchedCollections = fetchedWasteCollectsAtAddress.collection
        else { return }
        
        var collections: [OSCAWasteCollect] = []
        
        for collection in fetchedCollections {
          guard let dateString = collection.date,
                let isoDate = Date.dateFromISOString(string: dateString)
          else { return }
          
          let now = Date()
          let wasteDate = isoDate.toLocalTime()
          
          if wasteDate.isAfterDate(now, orEqual: true, granularity: .weekdayOrdinal) {
            collections.append(collection)
          }
        }
        
        self.wasteCollects = collections.sorted(by: {
          guard let firstString = $0.date,
                let secondString = $1.date,
                let firstDate = Date.dateFromISOString(string: firstString),
                let secondDate = Date.dateFromISOString(string: secondString)
          else { return false }
          
          return firstDate < secondDate
        })
      }
      .store(in: &self.bindings)
  }
}

// MARK: - Localized Strings
extension OSCAWasteAppointmentViewModelWidget {
  public var widgetTitle: String { NSLocalizedString(
    "waste_widget_title",
    bundle: self.bundle,
    comment: "The widget title") }
  var alertTitleError: String { NSLocalizedString(
    "waste_alert_title_error",
    bundle: self.bundle,
    comment: "The alert title for an error") }
  var alertActionConfirm: String { NSLocalizedString(
    "waste_alert_title_confirm",
    bundle: self.bundle,
    comment: "The alert action title to confirm") }
}

// MARK: - INPUT. View event methods
extension OSCAWasteAppointmentViewModelWidget {
  func viewDidLoad() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.fetchWasteCollects),
      name: .userWasteAddressDidChange,
      object: nil)
    
    self.fetchWasteCollects()
  }
}

extension OSCAWasteAppointmentViewModelWidget {
  @objc private func filtersDidChange(notification: NSNotification) {
    self.fetchWasteCollects()
  }
}
