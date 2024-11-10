//
//  ScreenDimensions.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/10/29.
//

import SwiftUI

class ScreenDimensions {
  #if os(iOS) || os(tvOS)
    static var width: CGFloat = UIScreen.main.bounds.size.width
    static var height: CGFloat = UIScreen.main.bounds.size.height
  #elseif os(macOS)
    static var width: CGFloat = NSScreen.main?.visibleFrame.size.width ?? 0
    static var height: CGFloat = NSScreen.main?.visibleFrame.size.height ?? 0
  #endif
}
