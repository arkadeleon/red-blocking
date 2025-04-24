//
//  CharacterBackgroundView.swift
//  MaCherie
//
//  Created by Li, Junlin on 2019/11/18.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import UIKit

class CharacterBackgroundView: UIView {
    let imageView: UIImageView

    override init(frame: CGRect) {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        super.init(frame: frame)

        backgroundColor = .systemGroupedBackground

        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        imageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
