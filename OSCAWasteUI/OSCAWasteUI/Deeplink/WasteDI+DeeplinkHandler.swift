//
//  WasteDI+DeeplinkHandler.swift
//  OSCAWasteUI
//
//  Created by Stephan Breidenbach on 08.09.22.
//

import Foundation
extension OSCAWasteUI.DIContainer {
  var deeplinkScheme: String {
    return self
      .dependencies
      .moduleConfig
      .deeplinkScheme
  }// end var deeplinkScheme
}// end extension final class OSCAWasteUI.DIContainer
