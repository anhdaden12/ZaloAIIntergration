//
//  ViewController.swift
//  ZaloAIIntergration
//
//  Created by Ngoc Bao on 5/28/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var textVIewContent: UITextView!
    
    var player: AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func getAllMembers(urlString: String) {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["input" : textVIewContent.text ?? "", "speed" : "1.0","encode_type": "0","speaker_id": "2"]
        request.httpBody = parameters.percentEncoded()

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(ZaloBase.self, from: data)
                    let urlstring = json.data.url
                    let url = NSURL(string: urlstring)
                    print("the url = \(url!)")
                    self.downloadFileFromURL(url: url!)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func downloadFileFromURL(url:NSURL){

        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url as URL, completionHandler: { [weak self](URL, response, error) -> Void in
            self?.play(url: URL! as NSURL)
        })
            
        downloadTask.resume()
        
    }
    
    func play(url:NSURL) {
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url as URL)
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    @IBAction func onClick() {
        getAllMembers(urlString: "https://api.zalo.ai/v1/tts/synthesize?apikey=s52lnVXOaOCjGf9Fwjuck0KO8vDWetUv")
    }

}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

class ZaloBase: Codable {
    var data: DataItem
    var error_message: String
    var error_code: Int
    
    init(data: DataItem, error_message: String, error_code: Int) {
       self.data = data
       self.error_message = error_message
       self.error_code = error_code
   }
}

class DataItem: Codable {
    
    var url: String
    
    init(url: String) {
        self.url = url
    }
}
