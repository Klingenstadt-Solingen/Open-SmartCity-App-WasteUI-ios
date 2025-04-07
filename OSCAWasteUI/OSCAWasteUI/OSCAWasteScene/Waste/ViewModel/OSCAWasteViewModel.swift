//
//  OSCAWasteViewModel.swift
//  OSCAWasteUI
//
//  Created by Ömer Kurutay on 23.06.22.
//

import OSCAEssentials
import OSCAWaste
import Foundation
import Combine

@_implementationOnly
import SwiftDate

public struct OSCAWasteViewModelActions {
  let showWasteAppointment: (OSCAWasteCollectsAtAddress, [Int]) -> Void
  let showWasteInfo: (OSCAWasteType) -> Void
  let showWasteGreenAndClothes: (WasteLocationType) -> Void
}

public final class OSCAWasteViewModel {
  
  let dataModule: OSCAWaste
  let dataCache: NSCache<NSString, NSData>
  private let actions: OSCAWasteViewModelActions?
  private var bindings = Set<AnyCancellable>()
  
  var userAddress: OSCAWasteAddress
  
  // MARK: Initializer
  public init(dataModule: OSCAWaste,
              dataCache: NSCache<NSString, NSData>,
              actions: OSCAWasteViewModelActions,
              userAddress: OSCAWasteAddress) {
    self.dataModule = dataModule
    self.dataCache = dataCache
    self.actions = actions
    self.userAddress = userAddress
  }
  
  // MARK: - OUTPUT
  
  enum Section { case wasteAppointment }
  
  @Published var wasteCollects: [OSCAWasteCollect] = []
  @Published var mondayCollections   : [OSCAWasteCollect] = []
  @Published var tuesdayCollections  : [OSCAWasteCollect] = []
  @Published var wednesdayCollections: [OSCAWasteCollect] = []
  @Published var thursdayCollections : [OSCAWasteCollect] = []
  @Published var fridayCollections   : [OSCAWasteCollect] = []
  @Published var saturdayCollections : [OSCAWasteCollect] = []
  @Published var sundayCollections   : [OSCAWasteCollect] = []
  
  @Published var filterTypes   : [OSCAWasteCollectBinType] = []
  @Published var wasteDistricts: [OSCAWasteGreenAndClothesDistrict] = []
  
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
  
  var noAppointmentsText: String {
    NSLocalizedString(
      "waste_widget_no_appointments",
      bundle: self.bundle,
      comment: "Message when appointment list is empty ")
  }
  
  var dateOfToday: String {
    return Date().dateByAdding(self.currentWeek, .weekOfYear)
      .date.toString(.custom("MMMM yyyy"))
  }
  
  var wasteUserFullStreetAddress: String? {
    return userAddress.fullAddress
  }
  
  var wasteCollectsAtAddress: OSCAWasteCollectsAtAddress? = nil
  var currentWeek: Int = 0 {
    didSet {
      self.loadCurrentWeeksCollections()
    }
  }
  
  // MARK: Localized Strings
  
  var screenTitle: String { NSLocalizedString(
    "waste_screen_title",
    bundle: self.bundle,
    comment: "The screen title") }
  var reminderTitle: String { NSLocalizedString(
    "waste_reminder_title",
    bundle: self.bundle,
    comment: "The reminder title") }
  var nextAppointmentTitle: String { NSLocalizedString(
    "waste_next_appointment_title",
    bundle: self.bundle,
    comment: "The title for the next waste appointment") }
  var allAppointmentTitle: String { NSLocalizedString(
    "waste_all_appointment_title",
    bundle: self.bundle,
    comment: "The title for all waste appointment") }
  var wasteTypeTitle: String { NSLocalizedString(
    "waste_waste_type_title",
    bundle: self.bundle,
    comment: "The title for waste type") }
  var pickedUpWasteTitle: String { NSLocalizedString(
    "waste_picked_up_waste_title",
    bundle: self.bundle,
    comment: "The title for picked up waste") }
  var greenMobileWasteTitle: String { NSLocalizedString(
      "waste_green_mobile_waste_title",
      bundle: self.bundle,
      comment: "The title for green cuttings waste") }
  var oldClothesWasteTitle: String { NSLocalizedString(
      "waste_old_clothes_waste_title",
      bundle: self.bundle,
      comment: "The title for green cuttings waste") }
  var specialWasteTitle: String { NSLocalizedString(
    "waste_special_waste_title",
    bundle: self.bundle,
    comment: "The title for special waste") }
  var showAllFilterOptionTitle: String {
    NSLocalizedString(
      "waste_filter_show_all_filter_option",
      bundle: self.bundle,
      comment: "Show all option name")
  }
  var filterButtonTitle: String {
    NSLocalizedString(
      "waste_filter_button_title",
      bundle: self.bundle,
      comment: "Show filter selection button title")
  }
  
  var filterConfirmTitle: String {
    NSLocalizedString(
      "waste_filter_bottom_sheet_confirm",
      bundle: self.bundle,
      comment: "Filter Bottom Sheet confirm button text ")
  }
  
  var filterCancelButtonTitle: String {
    NSLocalizedString(
      "waste_filter_bottom_sheet_cancel",
      bundle: self.bundle,
      comment: "Filter Bottom Sheet cancel button text")
  }
  // MARK: - Private
  private func resetWeekCollections() {
    self.mondayCollections.removeAll()
    self.tuesdayCollections.removeAll()
    self.wednesdayCollections.removeAll()
    self.thursdayCollections.removeAll()
    self.fridayCollections.removeAll()
    self.saturdayCollections.removeAll()
    self.sundayCollections.removeAll()
  }
  
  private func loadCurrentWeeksCollections() {
    let now = Date().dateByAdding(self.currentWeek, .weekOfYear)
      .date
    
    resetWeekCollections()
    
    for collect in self.wasteCollects {
      guard let dateString = collect.date,
            let isoDate = Date.dateFromISOString(string: dateString)
      else { return }
      
      let wasteDate = isoDate.toLocalTime()
      
      if now.weekOfYear == wasteDate.weekOfYear {
        switch wasteDate.weekday {
        case 2: self.mondayCollections.append(collect)
        case 3: self.tuesdayCollections.append(collect)
        case 4: self.wednesdayCollections.append(collect)
        case 5: self.thursdayCollections.append(collect)
        case 6: self.fridayCollections.append(collect)
        case 7: self.saturdayCollections.append(collect)
        default: break
        }
      }
      if now.dateByAdding(1, .weekOfYear).weekOfYear == wasteDate.weekOfYear {
        if wasteDate.weekday == 1 {
          self.sundayCollections.append(collect)
        }
      }
    }
  }

private func getBinTypeFilters() {
  guard let wasteAddress = try? self.dataModule.userDefaults.getOSCAWasteAddress() else { return }
  self.dataModule.fetchAvailableBinTypes(for: wasteAddress)
    .sink { completion in
      switch completion {
      case .finished:
        print(".finished \(#function)")
        
      case .failure:
        print(".failure \(#function)")
      }
      
    } receiveValue: { availableBinTypes in
      self.filterTypes = availableBinTypes
      self.updateCollectBinTypes()
      self.wasteCollectsAtAddress?.collection = self.wasteCollects
    } .store(in: &bindings)
  }
  
  private func updateCollectBinTypes() {
    for index in self.wasteCollects.indices {
      guard let collectFilterType = self.wasteCollects[index].filterTypeId else {
        print("No matching filter found for type id = \(self.wasteCollects[index].filterTypeId ?? -1), collection skipped")
        break
      }
      let matchingType = self.filterTypes.first { collectFilterType == $0.id }
      self.wasteCollects[index].setBinType(matchingType)
    }
  }
  
  @objc private func getWasteCollects() {
    if let wasteAddress = try? self.dataModule.userDefaults.getOSCAWasteAddress() {
      self.userAddress = wasteAddress
      
    } else {
      self.dataModule.userDefaults.setOSCAWasteReminder(false)
    }
    
    let selectedBinTypes = self.dataModule.userDefaults.getOSCAWasteSelectedBinTypeIds()
    self.dataModule.fetchWasteCollections(for: self.userAddress, binTypes: selectedBinTypes)
      .sink { completion in
        switch completion {
        case .finished:
          print(".finished \(#function)")
          
        case .failure:
          print(".failure \(#function)")
            self.resetWeekCollections()
            self.wasteCollects = []
            self.wasteCollectsAtAddress?.collection = []
        }
        
      } receiveValue: { wasteCollectsAtAddress in
        self.wasteCollectsAtAddress = wasteCollectsAtAddress
        var collections: [OSCAWasteCollect] = []
        
        self.resetWeekCollections() 
        
        for collection in wasteCollectsAtAddress.collection! {
          guard let dateString = collection.date,
                let isoDate = Date.dateFromISOString(string: dateString)
          else { return }
          
          let now = Date()
          let wasteDate = isoDate.toLocalTime()
          
          if now.weekOfYear == wasteDate.weekOfYear {
            switch wasteDate.weekday {
            case 2: self.mondayCollections.append(collection)
            case 3: self.tuesdayCollections.append(collection)
            case 4: self.wednesdayCollections.append(collection)
            case 5: self.thursdayCollections.append(collection)
            case 6: self.fridayCollections.append(collection)
            case 7: self.saturdayCollections.append(collection)
            default: break
            }
          }
          if now.dateByAdding(1, .weekOfYear).weekOfYear == wasteDate.weekOfYear {
            if wasteDate.weekday == 1 {
              self.sundayCollections.append(collection)
            }
          }
          
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
        
        self.updateCollectBinTypes()
        self.wasteCollectsAtAddress?.collection = self.wasteCollects
      }
      .store(in: &bindings)
    
  }
}

// MARK: - Input, view event methods
extension OSCAWasteViewModel {
  func viewDidLoad(callback:@escaping (_ districts: [OSCAWasteGreenAndClothesDistrict])->Void) {
      self.getWasteDistricts(callback: callback)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.getWasteCollects),
      name: .userWasteAddressDidChange,
      object: nil)
    
    self.getWasteCollects()
    self.getBinTypeFilters()
  }
  
  func nextWeekButtonTouch() {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    self.currentWeek += 1
  }
  
  func previousWeekButtonTouch() {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    self.currentWeek -= 1
  }
  
  func reminderSwitchTouch(_ isReminding: Bool) {
    self.dataModule.userDefaults.setOSCAWasteReminder(isReminding)
  }
  
  func allAppointmentButtonTouch() {
    guard let wasteCollectsAtAddress = wasteCollectsAtAddress else { return }
    let selectedBinTypes = self.dataModule.userDefaults.getOSCAWasteSelectedBinTypeIds()
    actions?.showWasteAppointment(wasteCollectsAtAddress, selectedBinTypes)
  }
    
  func pickedUpWasteButtonTouch(wasteType: OSCAWasteType) {
    actions?.showWasteInfo(wasteType)
  }
  
    func greenAndClothesWasteButtonTouch(wasteLocationType: WasteLocationType) {
        actions?.showWasteGreenAndClothes(wasteLocationType)
  }
  
  func specialWasteButtonTouch(wasteType: OSCAWasteType) {
    actions?.showWasteInfo(wasteType)
  }
    
    private func getWasteDistricts(callback: @escaping(_ districts: [OSCAWasteGreenAndClothesDistrict])->Void) {
        self.dataModule
            .fetchWasteGreenAndClothesDistrict(
                wasteLocationType: .Grünschnittcontainer
            )
      .sink { completion in
        switch completion {
        case .finished:
          print(".finished \(#function)")
          
        case .failure:
          print(completion)
          print(".failure \(#function)")
        }
        
      } receiveValue: { wasteDistricts in
        self.wasteDistricts = wasteDistricts
        callback(wasteDistricts)
      }
      .store(in: &self.bindings)
  }
  
  func didSelect(at title: String) {
      var districts: [String]? = []
      if let userDistricts: [String] = UserDefaults.standard.stringArray(
        forKey: OSCAWaste.greenWasteAppointmentDistrictsKey
      ) {
          var newDistricts = userDistricts
          if (!userDistricts.contains(where: { district in district == title })) {
              newDistricts.append(title)
          }
          districts = newDistricts
      } else {
          districts = [title]
      }
      UserDefaults.standard.set(districts, forKey: OSCAWaste.greenWasteAppointmentDistrictsKey)
      self.getWasteCollects()
  }
    
  func didDeselect(at title: String) {
      var districts: [String]? = nil
      if let userDistricts: [String] = UserDefaults.standard.stringArray(
        forKey: OSCAWaste.greenWasteAppointmentDistrictsKey
      ) {
          districts = userDistricts.filter({ district in district != title})
      }
      UserDefaults.standard.set(districts, forKey: OSCAWaste.greenWasteAppointmentDistrictsKey)
      self.getWasteCollects()
  }
}


extension OSCAWasteViewModel {
  func onFiltersSelected(_ filters: [OSCAWasteCollectBinType]) {
    let ids = filters.compactMap { $0.id }
    do {
      try self.dataModule.userDefaults.setOSCAWasteSelectedBinTypes(ids: ids)
      self.getWasteCollects()
      
      NotificationCenter.default.post(name: .userWasteFiltersDidChange, object: nil)
    } catch {
      #if DEBUG
      print("OSCAWasteViewModel: Error trying to set selected bin types on user defaults")
      #endif
    }
  }
}

public extension NSNotification.Name {
  static let userWasteFiltersDidChange = Notification.Name(rawValue: "OSCAWaste_Filters_DidChange")
}
