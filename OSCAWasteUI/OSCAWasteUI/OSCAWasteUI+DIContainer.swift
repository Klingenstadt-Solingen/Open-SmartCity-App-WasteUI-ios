//
//  OSCAWasteUI+DIContainer.swift
//  OSCAWasteUI
//
//  Created by Stephan Breidenbach on 03.06.22.
//

import OSCAWaste
import OSCAEssentials
import OSCASafariView
import UIKit

extension OSCAWasteUI {
  final class DIContainer {
    var defaultLocation: OSCAGeoPoint? { dependencies.dataModule.defaultGeoPoint }
    let dependencies      : OSCAWasteUI.Dependencies
    
    public init(dependencies: OSCAWasteUI.Dependencies){
      self.dependencies = dependencies
    }// end public init
    
    // MARK: - OSCAWaste data module
    func makeOSCAWasteModule() -> OSCAWaste {
      return self.dependencies.dataModule
    }// end func makeOSCAWasteModule
    
    // MARK: - OSCAWasteUI config
    func makeWasteUIConfig() -> OSCAWasteUI.Config {
      return OSCAWasteUI.configuration
    }// end func makeWasteUIConfig
    
    // MARK: - OSCAWasteUI color config
    func makeWasteUIColorConfig() -> OSCAColorSettings {
      guard let colorSettings = OSCAWasteUI.configuration.colorConfig as? OSCAColorSettings
      else { return OSCAColorSettings() }
      return colorSettings
    }// end func makeWasteUIColorConfig
    
    // MARK: - OSCAWasteUI font settings
    func makeWasteUIFontConfig() -> OSCAFontSettings {
      guard let fontSettings = OSCAWasteUI.configuration.fontConfig as? OSCAFontSettings
      else { return OSCAFontSettings() }
      return fontSettings
    }// end func makeWasteUIFontConfig
    
    // MARK: - Flow Coordinators
    func makeWasteFlowCoordinator(router: Router) -> OSCAWasteFlowCoordinator {
      return OSCAWasteFlowCoordinator(router: router, dependencies: self)
    }
    
    func makeWasteSetupFlowCoordinator(router: Router) -> OSCAWasteSetupFlowCoordinator {
      return OSCAWasteSetupFlowCoordinator(router: router, dependencies: self)
    }
    
    func makeWasteWidgetFlowCoordinator(router: Router) -> OSCAWasteWidgetFlowCoordinator {
      return OSCAWasteWidgetFlowCoordinator(router: router, dependencies: self)
    }
    
    func makeSafariViewFlowCoordinator(router: Router, url: URL) -> OSCASafariViewFlowCoordinator {
      return dependencies.webViewModule.getSafariViewFlowCoordinator(router: router, url: url)
    }
  }// end final class DIContainer
}// end extension OSCAWasteUI

extension OSCAWasteUI.DIContainer: OSCAWasteFlowCoordinatorDependencies {
  
  
  // MARK: Waste
  public func makeOSCAWasteViewController(actions: OSCAWasteViewModelActions, userAddress: OSCAWasteAddress) -> OSCAWasteViewController {
    return OSCAWasteViewController.create(with: makeOSCAWasteViewModel(actions: actions, userAddress: userAddress))
  }
  
  public func makeOSCAWasteViewModel(actions: OSCAWasteViewModelActions, userAddress: OSCAWasteAddress) -> OSCAWasteViewModel {
    return OSCAWasteViewModel(
      dataModule: dependencies.dataModule,
      dataCache: dependencies.dataCache,
      actions: actions,
      userAddress: userAddress)
  }
  
  // MARK: Waste Appointment
  public func makeOSCAWasteAppointmentViewController(wasteCollectsAtAddress: OSCAWasteCollectsAtAddress, binTypes: [Int]) -> OSCAWasteAppointmentViewController {
    return OSCAWasteAppointmentViewController.create(with: makeOSCAWasteAppointmentViewModel(wasteCollectsAtAddress: wasteCollectsAtAddress, binTypes: binTypes))
  }
  
  public func makeOSCAWasteAppointmentViewModel(wasteCollectsAtAddress: OSCAWasteCollectsAtAddress, binTypes: [Int]) -> OSCAWasteAppointmentViewModel {
    return OSCAWasteAppointmentViewModel(
      dataModule: self.dependencies.dataModule,
      dataCache: self.dependencies.dataCache,
      wasteCollectsAtAddress: wasteCollectsAtAddress, binTypes: binTypes)
  }
  
  // MARK: Waste Info
  public func makeOSCAWasteInfoViewController(actions: OSCAWasteInfoViewModelActions, wasteType: OSCAWasteType) -> OSCAWasteInfoViewController {
    return OSCAWasteInfoViewController.create(with: makeOSCAWasteInfoViewModel(actions: actions, wasteType: wasteType))
  }
    
  public func makeOSCAWasteInfoViewModel(actions: OSCAWasteInfoViewModelActions, wasteType: OSCAWasteType) -> OSCAWasteInfoViewModel {
    return OSCAWasteInfoViewModel(dataModule: dependencies.dataModule, actions: actions, wasteType: wasteType)
  }
    
  public func makeOSCAWasteGreenAndClothesViewController(wasteLocationType: WasteLocationType) -> OSCAWasteGreenAndClothesViewController {
      return OSCAWasteGreenAndClothesViewController.create(with: makeOSCAWasteGreenAndClothesViewModel(wasteLocationType: wasteLocationType))
  }
    
  public func makeOSCAWasteGreenAndClothesViewModel(wasteLocationType: WasteLocationType) -> OSCAWasteGreenAndClothesViewModel {
      return OSCAWasteGreenAndClothesViewModel(wasteLocationType: wasteLocationType, dataModule: dependencies.dataModule)
  }
  
  // MARK: Waste Description
  public func makeOSCAWasteDescriptionViewController(actions: OSCAWasteDescriptionViewModelActions,
                                                     wasteInfo: OSCAWasteInfo?,
                                                     wasteType: OSCAWasteType,
                                                     wasteSubtype: OSCAWasteSubtype?,
                                                     wasteSpecialSubtype: OSCAWasteLocation?,
                                                     defaultLocation: OSCAGeoPoint?) -> OSCAWasteDescriptionViewController {
    let viewModel = makeOSCAWasteDescriptionViewModel(actions: actions,
                                                      wasteInfo: wasteInfo,
                                                      wasteType: wasteType,
                                                      wasteSuptype: wasteSubtype,
                                                      wasteSpecialSubtype: wasteSpecialSubtype,
                                                      defaultLocation: defaultLocation)
    return OSCAWasteDescriptionViewController.create(with: viewModel)
  }
  
  public func makeOSCAWasteDescriptionViewModel(actions: OSCAWasteDescriptionViewModelActions,
                                                wasteInfo: OSCAWasteInfo?,
                                                wasteType: OSCAWasteType,
                                                wasteSuptype: OSCAWasteSubtype?,
                                                wasteSpecialSubtype: OSCAWasteLocation?,
                                                defaultLocation: OSCAGeoPoint?) -> OSCAWasteDescriptionViewModel {
    return OSCAWasteDescriptionViewModel(actions: actions,
                                         wasteInfo: wasteInfo,
                                         wasteType: wasteType,
                                         wasteSuptype: wasteSuptype,
                                         wasteSpecialSubtype: wasteSpecialSubtype,
                                         defaultLocation: defaultLocation)
  }
}

extension OSCAWasteUI.DIContainer: OSCAWasteSetupFlowCoordinatorDependencies {
  // MARK: Waste Setup
  func makeOSCAWasteSetupViewController(actions: OSCAWasteSetupViewModelActions) -> OSCAWasteSetupViewController {
    return OSCAWasteSetupViewController.create(with: makeOSCAWasteSetupViewModel(actions: actions))
  }
  
  func makeOSCAWasteSetupViewModel(actions: OSCAWasteSetupViewModelActions) -> OSCAWasteSetupViewModel {
    return OSCAWasteSetupViewModel(dataModule: dependencies.dataModule, actions: actions)
  }
}

extension OSCAWasteUI.DIContainer: OSCAWasteWidgetFlowCoordinatorDependencies {
  func makeOSCAWasteAppointmentViewModelWidget(actions: OSCAWasteAppointmentViewModelWidget.Actions) -> OSCAWasteAppointmentViewModelWidget {
    let dependencies = OSCAWasteAppointmentViewModelWidget.Dependencies(
      actions: actions,
      dataModule: self.dependencies.dataModule,
      moduleConfig: self.dependencies.moduleConfig,
      dataCache: self.dependencies.dataCache)
    return OSCAWasteAppointmentViewModelWidget(dependencies: dependencies)
  }
  
  func makeOSCAWasteAppointmentViewControllerWidget(actions: OSCAWasteAppointmentViewModelWidget.Actions) -> OSCAWasteAppointmentViewControllerWidget {
    let viewModel = self.makeOSCAWasteAppointmentViewModelWidget(actions: actions)
    return OSCAWasteAppointmentViewControllerWidget.create(with: viewModel)
  }
}
