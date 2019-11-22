//
//  MusicViewController.swift
//  MaCherie
//
//  Created by Li, Junlin on 2019/11/18.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import UIKit
import AVKit
import XMLParsing

class MusicViewController: UITableViewController {
    private let player = AVPlayer()
    private var audios: [S3Object] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl!.beginRefreshing()
        refreshControlAction(refreshControl!)
    }
    
    @IBAction func refreshControlAction(_ sender: Any) {
        let url = URL(string: "https://game-institute.nyc3.digitaloceanspaces.com/?prefix=ma-cherie/music/")!
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
            self.audios = objectList?.objects ?? []
        }.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audios.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.audioCell, for: indexPath)!
        let path = audios[indexPath.row].key as NSString
        let lastPathComponent = path.lastPathComponent as NSString
        cell.textLabel?.text = lastPathComponent.deletingPathExtension
        cell.textLabel?.numberOfLines = 2
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = audios[indexPath.row]
        let baseURL = URL(string: "https://game-institute.nyc3.digitaloceanspaces.com")!
        let url = baseURL.appendingPathComponent(audio.key)
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.play()
    }
}
