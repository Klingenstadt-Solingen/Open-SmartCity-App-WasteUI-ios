//
//  OSCAWasteUITests.swift
//  OSCAWasteUITests
//
//  Created by Stephan Breidenbach on 03.06.22.
//
#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import XCTest
@testable import OSCAWasteUI
@testable import OSCAWaste
import OSCATestCaseExtension
import OSCAEssentials
import OSCASafariView

class OSCAWasteUITests: XCTestCase {
  static let moduleVersion = "1.1.2"
  override func setUpWithError() throws {
    try super.setUpWithError()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }// end override func setUpWithError
  
  override func tearDownWithError() throws {
    try super .tearDownWithError()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }// end override func tearDownWithError
  
  func testModuleInit() throws -> Void {
    let uiModule = try makeDevUIModule()
    XCTAssertNotNil(uiModule)
    XCTAssertEqual(uiModule.version, OSCAWasteUITests.moduleVersion)
    XCTAssertEqual(uiModule.bundlePrefix, "de.osca.waste.ui")
    let bundle = OSCAWaste.bundle
    XCTAssertNotNil(bundle)
    let uiBundle = OSCAWasteUI.bundle
    XCTAssertNotNil(uiBundle)
    let configuration = OSCAWasteUI.configuration
    XCTAssertNotNil(configuration)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
  }// end func testModuleInit
  
  func testContactUIConfiguration() throws -> Void {
    let _ = try makeDevUIModule()
    let uiModuleConfig = try makeUIModuleConfig()
    XCTAssertEqual(OSCAWasteUI.configuration.title, uiModuleConfig.title)
    XCTAssertEqual(OSCAWasteUI.configuration.colorConfig.accentColor, uiModuleConfig.colorConfig.accentColor)
    XCTAssertEqual(OSCAWasteUI.configuration.fontConfig.bodyHeavy, uiModuleConfig.fontConfig.bodyHeavy)
  }// end func testEventsUIConfiguration
}// end final class OSCAWasteUITests

// MARK: - factory methods
extension OSCAWasteUITests {
  public func makeDevModuleDependencies() throws -> OSCAWasteDependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.waste.ui")
    let dependencies = OSCAWasteDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeDevModuleDependencies
  
  public func makeDevModule() throws -> OSCAWaste {
    let devDependencies = try makeDevModuleDependencies()
    // initialize module
    let module = OSCAWaste.create(with: devDependencies)
    return module
  }// end public func makeDevModule
  
  public func makeProductionModuleDependencies() throws -> OSCAWasteDependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.waste.ui")
    let dependencies = OSCAWasteDependencies(
      networkService: networkService,
      userDefaults: userDefaults)
    return dependencies
  }// end public func makeProductionModuleDependencies
  
  public func makeProductionModule() throws -> OSCAWaste {
    let productionDependencies = try makeProductionModuleDependencies()
    // initialize module
    let module = OSCAWaste.create(with: productionDependencies)
    return module
  }// end public func makeProductionModule
  
  public func makeUIModuleConfig() throws -> OSCAWasteUI.Config {
    return OSCAWasteUI.Config(title: "OSCAWasteUI",
                              fontConfig: OSCAFontSettings(),
                              colorConfig: OSCAColorSettings())
  }// end public func makeUIModuleConfig
  
  public func makeWebViewModule() throws -> OSCASafariView {
    let moduleConfig = OSCASafariView.Config(title: "OSCASafariView",
                                             fontConfig: OSCAFontSettings(),
                                             colorConfig: OSCAColorSettings())
    let dependencies = OSCASafariView.Dependencies(moduleConfig: moduleConfig)
    let webViewModule = OSCASafariView.create(with: dependencies)
    return webViewModule
  }
  
  public func makeDevUIModuleDependencies() throws -> OSCAWasteUI.Dependencies {
    let module      = try makeDevModule()
    let uiConfig    = try makeUIModuleConfig()
    let webViewModule = try makeWebViewModule()
    return OSCAWasteUI.Dependencies( moduleConfig: uiConfig,
                                     dataModule: module,
                                     webViewModule: webViewModule)
  }// end public func makeDevUIModuleDependencies
  
  public func makeDevUIModule() throws -> OSCAWasteUI {
    let devDependencies = try makeDevUIModuleDependencies()
    // init ui module
    let uiModule = OSCAWasteUI.create(with: devDependencies)
    return uiModule
  }// end public func makeUIModule
  
  public func makeProductionUIModuleDependencies() throws -> OSCAWasteUI.Dependencies {
    let module      = try makeProductionModule()
    let uiConfig    = try makeUIModuleConfig()
    let webViewModule = try makeWebViewModule()
    return OSCAWasteUI.Dependencies( moduleConfig: uiConfig,
                                     dataModule: module,
                                     webViewModule: webViewModule)
  }// end public func makeProductionUIModuleDependencies
  
  public func makeProductionUIModule() throws -> OSCAWasteUI {
    let productionDependencies = try makeProductionUIModuleDependencies()
    // init ui module
    let uiModule = OSCAWasteUI.create(with: productionDependencies)
    return uiModule
  }// end public func makeProductionUIModule
}// end extension OSCAWasteUITests
#endif
