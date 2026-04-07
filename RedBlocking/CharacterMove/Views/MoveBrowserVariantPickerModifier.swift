//
//  MoveBrowserVariantPickerModifier.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MoveBrowserVariantPickerModifier: ViewModifier {
    let variantNames: [String]
    @Binding var selection: Int

    func body(content: Content) -> some View {
        if variantNames.isEmpty {
            content
        } else if #available(iOS 26, *) {
            content.safeAreaBar(edge: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Variant")
                        .redBlockingSectionTag()

                    Picker("", selection: $selection) {
                        ForEach(variantNames.indices, id: \.self) { index in
                            Text(variantNames[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Variant")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .redBlockingControlSurface(cornerRadius: 20, highlighted: true)
            }
        } else {
            content.safeAreaInset(edge: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Variant")
                        .redBlockingSectionTag()

                    Picker("", selection: $selection) {
                        ForEach(variantNames.indices, id: \.self) { index in
                            Text(variantNames[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Variant")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .redBlockingControlSurface(cornerRadius: 20, highlighted: true)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.bar)
            }
        }
    }
}

#Preview("Move Browser Variant Picker Modifier") {
    @Previewable @State var selection = 0

    return NavigationStack {
        ScrollView {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.rbCoal.opacity(0.4))
                .frame(height: 420)
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
        }
        .modifier(
            MoveBrowserVariantPickerModifier(
                variantNames: ["Normal", "SA I", "SA II"],
                selection: $selection
            )
        )
        .navigationTitle("Move Browser")
    }
}
