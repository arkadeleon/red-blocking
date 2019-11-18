//
//  PlaylistsViewController.swift
//  MaCherie
//
//  Created by Li, Junlin on 2019/11/18.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import UIKit

class PlaylistsViewController: UITableViewController {
    private var playlists: [Playlist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc private func refreshControlAction(_ sender: Any) {
        let url = URL(string: "https://game-institute.nyc3.digitaloceanspaces.com/?prefix=ma-cherie/videos/&marker=\("")")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let objectList = try? decoder.decode(S3ObjectList.self, from: data)
            
            let playlists = objectList?.objects?.reduce([:], { (playlists, object) -> [String : [S3Object]] in
                let components = object.key.split(separator: "/")
                guard components.count >= 3 else {
                    return playlists
                }
                
                let title = String(components[1])
                var videos = playlists[title] ?? []
                videos.append(object)
                
                var playlists = playlists
                playlists[title] = videos
                return playlists
            }) ?? [:]
            self.playlists = playlists.map { (playlist) -> Playlist in
                Playlist(title: playlist.key, videos: playlist.value)
            }
            self.tableView.reloadData()
        }.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
}
