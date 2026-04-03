//
//  MoveBrowserView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveBrowserView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedVariant = 0

    let model: MoveBrowserModel

    private var activeSections: [MoveBrowserSection] {
        if model.page.variantNames.isEmpty {
            return model.page.sections
        }
        guard model.page.variantSections.indices.contains(selectedVariant) else {
            return []
        }
        return model.page.variantSections[selectedVariant]
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                if let errorMessage = model.errorMessage {
                    ContentUnavailableView(
                        "Couldn't Load Moves",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .redBlockingPanel()
                } else if activeSections.isEmpty {
                    ContentUnavailableView(
                        "No Moves Here",
                        systemImage: "list.bullet.rectangle",
                        description: Text("This section doesn't contain any moves.")
                    )
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .redBlockingPanel()
                } else {
                    ForEach(activeSections) { section in
                        MoveBrowserSectionPanel(section: section, model: model)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.top, 20, for: .scrollContent)
        .contentMargins(.horizontal, horizontalContentMargin, for: .scrollContent)
        .contentMargins(.bottom, 28, for: .scrollContent)
        .navigationTitle(model.page.navigationTitle)
        .modifier(VariantPickerBar(variantNames: model.page.variantNames, selection: $selectedVariant))
        .onChange(of: model.page.id) { selectedVariant = 0 }
    }

    private var horizontalContentMargin: CGFloat {
        horizontalSizeClass == .regular ? 24 : 16
    }
}

private struct VariantPickerBar: ViewModifier {
    let variantNames: [String]
    @Binding var selection: Int

    func body(content: Content) -> some View {
        if variantNames.isEmpty {
            content
        } else if #available(iOS 26, *) {
            content.safeAreaBar(edge: .top) {
                pickerView
            }
        } else {
            content.safeAreaInset(edge: .top) {
                pickerView
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.bar)
            }
        }
    }

    private var pickerView: some View {
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
}
