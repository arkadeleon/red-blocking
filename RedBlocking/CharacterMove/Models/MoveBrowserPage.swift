//
//  MoveBrowserPage.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/13.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

struct MoveBrowserPage: Hashable, Identifiable {
    let id: String
    let navigationTitle: String
    let sections: [MoveBrowserSection]
    let variantNames: [String]
    let variantSections: [[MoveBrowserSection]]

    init(
        id: String,
        navigationTitle: String,
        sections: [MoveBrowserSection],
        variantNames: [String] = [],
        variantSections: [[MoveBrowserSection]] = []
    ) {
        self.id = id
        self.navigationTitle = navigationTitle
        self.sections = sections
        self.variantNames = variantNames
        self.variantSections = variantSections
    }
}
