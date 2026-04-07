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
        guard model.page.variantSections.indices.contains(resolvedSelectedVariant) else {
            return model.page.sections
        }
        return model.page.variantSections[resolvedSelectedVariant]
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
        .modifier(
            MoveBrowserVariantPickerBar(
                variantNames: model.page.variantNames,
                selection: Binding(
                    get: { resolvedSelectedVariant },
                    set: { selectedVariant = clampedVariantIndex(for: $0) }
                )
            )
        )
        .onChange(of: model.page.id) { _, _ in
            selectedVariant = 0
        }
    }

    private var horizontalContentMargin: CGFloat {
        horizontalSizeClass == .regular ? 24 : 16
    }

    private var resolvedSelectedVariant: Int {
        clampedVariantIndex(for: selectedVariant)
    }

    private func clampedVariantIndex(for index: Int) -> Int {
        let upperBound = model.page.variantSections.count - 1
        guard upperBound >= 0 else {
            return 0
        }

        return min(max(index, 0), upperBound)
    }
}

#Preview("Move Browser View") {
    let preview = PreviewAppModel.moveBrowserModel()

    return NavigationStack {
        MoveBrowserView(model: preview.model)
    }
    .environment(preview.appModel)
}
