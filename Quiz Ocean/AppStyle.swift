//
//  AppStyle.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/10/27.
//

import SwiftUI

struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.all)
    }
}

extension View {
    func applyBackground() -> some View {
        self.modifier(BackgroundModifier())
    }
}
