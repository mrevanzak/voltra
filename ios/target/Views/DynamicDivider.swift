//
//  DynamicDivider.swift
//  VoltraUI
//
//  Created by Saul Sharma.
//  https://x.com/saul_sharma
//
//  https://github.com/saulsharma/voltra
//  MIT LICENCE

import SwiftUI

public struct DynamicDivider: View {
    @Environment(\.internalVoltraUIEnvironment)
    private var voltraUIEnvironment

    private let component: VoltraUIComponent

    init(_ component: VoltraUIComponent) {
        self.component = component
    }

    public var body: some View {
        Divider()
            .voltraUIModifiers(component)
    }
}
