//
//  DynamicSpacer.swift
//  VoltraUI
//
//  Created by Saul Sharma.
//  https://x.com/saul_sharma
//
//  https://github.com/saulsharma/voltra
//  MIT LICENCE

import SwiftUI

public struct DynamicSpacer: View {
    @Environment(\.internalVoltraUIEnvironment)
    private var voltraUIEnvironment

    private let component: VoltraUIComponent

    private var params: SpacerParameters? {
        component.parameters(SpacerParameters.self)
    }

    init(_ component: VoltraUIComponent) {
        self.component = component
    }

    public var body: some View {
        Spacer(minLength: params?.minLength.map { CGFloat($0) })
            .voltraUIModifiers(component)
    }
}
