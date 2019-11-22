//
//  PlaylistsViewController.swift
//  MaCherie
//
//  Created by Li, Junlin on 2019/11/18.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import UIKit
import XMLParsing

struct Playlist {
    var title: String
    var videos: [S3Object]
}

class PlaylistsViewController: UITableViewController {
    private var playlists: [Playlist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl!.beginRefreshing()
        refreshControlAction(refreshControl!)
    }
    
    @IBAction func refreshControlAction(_ sender: Any) {
        let url = URL(string: "https://game-institute.nyc3.digitaloceanspaces.com/?prefix=ma-cherie/videos/&marker=\("")")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            defer {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
            
            guard let data = data else {
                return
            }
            
            let decoder = XMLDecoder()
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            let objectList = try? decoder.decode(S3ObjectList.self, from: data)
            
            let playlists = objectList?.objects?.reduce([:], { (playlists, object) -> [String : [S3Object]] in
                let components = object.key.split(separator: "/")
                guard components.count >= 4 else {
                    return playlists
                }
                
                let title = String(components[2])
                var videos = playlists[title] ?? []
                videos.append(object)
                
                var playlists = playlists
                playlists[title] = videos
                return playlists
            }) ?? [:]
            self.playlists = playlists.map { (playlist) -> Playlist in
                Playlist(title: playlist.key, videos: playlist.value)
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case R.segue.playlistsViewController.showVideos.identifier:
            let indexPath = tableView.indexPathForSelectedRow!
            let videosViewController = segue.destination as! VideosViewController
            videosViewController.videos = playlists[indexPath.row].videos
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.playlistCell, for: indexPath)!
        cell.textLabel?.text = playlists[indexPath.row].title
        return cell
    }
}
