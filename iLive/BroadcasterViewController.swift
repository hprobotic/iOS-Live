//
//  BroadcasterViewController.swift
//  iLive
//
//  Created by JohnP on 5/12/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import UIKit
import SocketIO
import LFLiveKit
import SVProgressHUD


class BroadcasterViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userNameLabel: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var inputTitleOverlay: UIVisualEffectView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var channelKey: UILabel!
    var channelID: String = ""
    var streamOverlayController: LiveOverlayViewController!
    var channel: Channel!
    let socket = SocketIOClient(socketURL: URL(string: Config.serverUrl)!, config: [.log(true), .forceWebsockets(true)])
    
    lazy var session: LFLiveSession = {
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: .medium3)
        
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)!
        session.delegate = self
        session.captureDevicePosition = .back
        session.preView = self.previewView
        return session
    }()
    
    func start() {
        channel = Channel(dict: [
            "title": nameTextField.text! as AnyObject,
            "key": String.random() as AnyObject
            ])
        
        let stream = LFLiveStreamInfo()
        stream.url = "\(Config.rtmpPushUrl)\(channel.key)"
        session.startLive(stream)
        socket.connect()
        socket.once("connect") {[weak self] data, ack in
            guard let this = self else {
                return
            }
            this.socket.emit("create_channel", this.channel.toDict())
        }
        channelKey.text = "\(channel.key)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.running = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.running = false
        stop()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "overlay" {
            streamOverlayController = segue.destination as! LiveOverlayViewController
            streamOverlayController.socket = socket
        }
        if segue.identifier == "goWatchView" {
            let toVC = segue.destination as! WatchViewController
            toVC.channelID = self.channelID
        }
    }
    
    func stop() {
        guard channel != nil  else {
            return
        }
        session.stopLive()
        socket.disconnect()
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
        stop()
        UIView.animate(withDuration: 0.2, animations: {
            self.inputTitleOverlay.alpha = 1
        }, completion: { finished in
            self.inputTitleOverlay.isHidden = false
        })
        userNameLabel.becomeFirstResponder()
    }
    @IBAction func startBtnPressed(_ sender: Any) {
        userNameLabel.resignFirstResponder()
        start()
        UIView.animate(withDuration: 0.2, animations: {
            self.inputTitleOverlay.alpha = 0
        }, completion: { finished in
            self.inputTitleOverlay.isHidden = true
        })
    }
    @IBAction func beauty(_ sender: Any) {
        if session.captureDevicePosition == .back {
            session.captureDevicePosition = .front
        } else {
            session.captureDevicePosition = .back
        }
    }
    @IBAction func viewLiveButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Channel ID", message: "Enter channel ID", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let text = textField?.text else { return }
            self.channelID = text
            self.performSegue(withIdentifier: "goWatchView", sender: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


extension BroadcasterViewController: LFLiveSessionDelegate {
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        switch state {
        case .error:
            statusLabel.text = "error"
        case .pending:
            statusLabel.text = "pending"
        case .ready:
            statusLabel.text = "ready"
        case.start:
            statusLabel.text = "start"
        case.stop:
            statusLabel.text = "stop"
        default: break
        statusLabel.text = "undefined"
        }
    }
    
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print("error: \(errorCode)")
        
    }
}

public extension String {
    static func random(_ length: Int = 4) -> String {
        let base = "abcdefghijklmnopqrstuvwxyz"
        var randomString: String = ""
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.characters.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
}
