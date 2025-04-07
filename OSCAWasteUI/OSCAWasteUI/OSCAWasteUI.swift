import OSCAEssentials
import OSCASafariView
import OSCAWaste
import UIKit

/// WasteUI module
public struct OSCAWasteUI {
  public struct Dependencies {
    let moduleConfig   : OSCAWasteUI.Config
    let dataModule     : OSCAWaste
    let analyticsModule: OSCAAnalyticsModule?
    let webViewModule  : OSCASafariView
    let dataCache: NSCache<NSString, NSData>
    
    public init(moduleConfig   : OSCAWasteUI.Config,
                dataModule     : OSCAWaste,
                analyticsModule: OSCAAnalyticsModule? = nil,
                webViewModule  : OSCASafariView,
                dataCache: NSCache<NSString, NSData> = NSCache<NSString, NSData>()
    ) {
      self.moduleConfig    = moduleConfig
      self.dataModule      = dataModule
      self.analyticsModule = analyticsModule
      self.webViewModule   = webViewModule
      self.dataCache = dataCache
    }// end public init
  }// end public struct OSCAWasteUI.Dependencies
  
  public struct Config: OSCAUIModuleConfig {
    /// module title
    public var title          : String?
    public var externalBundle : Bundle?
    /// `UIView` corner radius
    public var cornerRadius   : Double = 10.0
    /// `UIView` border thickness
    public var borderThickness: Double = 1.5
    /// typeface configuration
    public var fontConfig     : OSCAFontConfig
    /// color configuration
    public var colorConfig    : OSCAColorConfig
    /// shadow configuration
    public var shadow         : OSCAShadowSettings
    /// Defines the visibility of additional space
    public var isAdditionalSpaceHidden: Bool
    /// Defines the visibility of additional space
    public var additionalSpaceText: String
    /// Defines the visibility of waste information
    public var isWasteInfoHidden: Bool
    /// Number of visible __OSCAWasteCollect__ items for __OSCAWasteAppointmentWidget__
    public var numberOfAppointments: Int
    /// user address
    public var userAddress         : OSCAWasteAddress?
    /// app deeplink scheme URL part before `://`
    public var deeplinkScheme      : String = "solingen"
    
    public var enableBinTypeFilter: Bool = false
    
    public init(title                  : String?,
                externalBundle         : Bundle? = nil,
                fontConfig             : OSCAFontSettings,
                colorConfig            : OSCAColorSettings,
                cornerRadius           : Double = 10.0,
                shadow                 : OSCAShadowSettings = OSCAShadowSettings(
                  opacity: 0.3,
                  radius: 10,
                  offset: CGSize(width: 0, height: 2)),
                isAdditionalSpaceHidden: Bool = true,
                additionalSpaceText    : String = "",
                isWasteInfoHidden      : Bool = false,
                numberOfAppointments   : Int = 2,
                userAddress            : OSCAWasteAddress? = nil,
                deeplinkScheme         : String = "solingen",
                enableBinTypeFilter: Bool = true) {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      self.title                   = title
      self.externalBundle          = externalBundle
      self.fontConfig              = fontConfig
      self.colorConfig             = colorConfig
      self.cornerRadius            = cornerRadius
      self.shadow                  = shadow
      self.isAdditionalSpaceHidden = isAdditionalSpaceHidden
      self.additionalSpaceText     = additionalSpaceText
      self.isWasteInfoHidden       = isWasteInfoHidden
      self.numberOfAppointments    = numberOfAppointments
      self.userAddress             = userAddress
      self.deeplinkScheme          = deeplinkScheme
      self.enableBinTypeFilter = enableBinTypeFilter
    }// end public memberwise init
  }// end public struct OSCAWasteUI.Config
  
  /// module DI container
  private var moduleDIContainer: OSCAWasteUI.DIContainer!
  /// version of the module
  public var version: String = "1.1.2"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.waste.ui"
  /// module configuration
  public internal(set) static var configuration: OSCAWasteUI.Config!
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!
  
  public init() {
    guard let bundle: Bundle = Bundle(identifier: self.bundlePrefix) else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
  }// end public init
}// end public struct OSCAWasteUI

extension OSCAWasteUI: OSCAModule {
  /**
   create module and inject module dependencies
   - Parameter mduleDependencies: module dependencies
   */
  public static func create(with moduleDependencies: OSCAWasteUI.Dependencies) -> OSCAWasteUI {
    var module: Self = Self.init(with: moduleDependencies.moduleConfig)
    module.moduleDIContainer = OSCAWasteUI.DIContainer(dependencies: moduleDependencies)
    return module
  }// end public static func create
  
  /// public initializer with module configuration
  /// - Parameter config: module configuration
  public init(with config: OSCAUIModuleConfig) {
#if SWIFT_PACKAGE
    Self.bundle = .module
#else
    guard let bundle: Bundle = Bundle(identifier: self.bundlePrefix)
    else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
#endif
    guard let extendedConfig = config as? OSCAWasteUI.Config
    else { fatalError("Config couldn't be initialized!") }
    OSCAWasteUI.configuration = extendedConfig
  }// end public init
  
  /**
   public module interface `getter`for `OSCAWasteFlowCoordinator`
   - Parameter router: router needed or the navigation graph
   */
  public func getWasteFlowCoordinator(router: Router) -> OSCAWasteFlowCoordinator {
    let flow = self.moduleDIContainer.makeWasteFlowCoordinator(router: router)
    return flow
  }
  
  /**
   public module interface `getter`for `OSCAWasteSetupFlowCoordinator`
   - Parameter router: router needed or the navigation graph
   */
  public func getWasteSetupFlowCoordinator(router: Router) -> OSCAWasteSetupFlowCoordinator {
    let flow = self.moduleDIContainer.makeWasteSetupFlowCoordinator(router: router)
    return flow
  }
  
  /**
   public module interface `getter`for `OSCAWasteWidgetFlowCoordinator`
   - Parameter router: router needed or the navigation graph
   */
  public func getWasteWidgetFlowCoordinator(router: Router) -> OSCAWasteWidgetFlowCoordinator {
    let flow = self.moduleDIContainer.makeWasteWidgetFlowCoordinator(router: router)
    return flow
  }
}// end extension public struct OSCAWasteUI
