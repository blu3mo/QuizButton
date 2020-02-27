//
//  ViewController.swift
//  QuizButton
//
//  Created by Shutaro Aoyama on 2019/04/16.
//  Copyright © 2019 Shutaro Aoyama. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AVFoundation

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    @IBOutlet weak var countLabel: UILabel!
        
    let screenSize = UIScreen.main.bounds
    var selfTime = Date()
    var opponentTime = Date()
    
    var count = 0
    
    var peerId: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var audioPlayer: AVAudioPlayer?
    
    var state = State.open
    enum State {
        case open
        case judging
        case done
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initial Multipeer Conectivity setup
        peerId = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        //Sound setup
        var fileURL = Bundle.main.path(forResource: "quizsound", ofType: "m4a")!
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
        } catch  {
            print("error on audio")
        }
    }
    
    
    // Connecting with other devices
    
    @IBAction func ConnectButtonTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Quiz Button", message: "Host or Join a session", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            self.advertise()
        }))

        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
            self.presentBrowser()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height/2, width: 0, height: 0)
        actionSheet.popoverPresentationController?.permittedArrowDirections = []
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func advertise() {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ba-td", discoveryInfo: nil, session: self.mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func presentBrowser() {
        let mcBrowser = MCBrowserViewController(serviceType: "ba-td", session: mcSession)
        mcBrowser.delegate = self
        mcBrowser.maximumNumberOfPeers = 1
        mcBrowser.minimumNumberOfPeers = 1
        present(mcBrowser, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // Sending Data
    @IBAction func answerButtonTapped(_ sender: Any) {
        playSound()
        sendTime()
    }
    
    func sendTime() {
        if mcSession.connectedPeers.count <= 0 { return }
        
        if state == .open {
            selfTime = Date()
            state = .judging
            //if self.state != .judging { //すでに相手は押している
            let timeString = stringFromDate(date: Date(), format: "y-MM-dd H:m:ss.SSSS")
            do {
                try mcSession.send(timeString.data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                print("hoo")
            }
        }
        
    }
    
    
    // Recieving Data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decodedData = String(data: data, encoding: .utf8)
        if decodedData == "youwin" {
            if state != .done {
                state = .done
                DispatchQueue.main.async { self.view.backgroundColor = .red }
            }
            return
        } else if state == .judging { //すでに自分は押している
            opponentTime = dateFromString(string: decodedData!, format: "y-MM-dd H:m:ss.SSSS")
            print(opponentTime)
            print(selfTime)
            if opponentTime < selfTime {
                DispatchQueue.main.async { self.view.backgroundColor = .black }
                state = .done
            } else {
                DispatchQueue.main.async { self.view.backgroundColor = .red }
                state = .done
            }
        } else if state == .open {
            DispatchQueue.main.async { self.view.backgroundColor = .black }
            state = .done
            do {
                try mcSession.send(("youwin").data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch { }
            
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
    func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        state = .open
        view.backgroundColor = UIColor(red:0.12, green:0.13, blue:0.14, alpha:1.0)
        selfTime = Date()
        opponentTime = Date()
    }
    
    // Score Counter
    
    @IBAction func addCounter(_ sender: UIButton) {
        count += sender.tag
        countLabel.text = String(count)
    }
    
    @IBAction func subtractCounter(_ sender: UIButton) {
        count -= sender.tag
        countLabel.text = String(count)
    }
    
    func playSound() {
        audioPlayer?.currentTime = 0         // 再生箇所を頭に移す
        audioPlayer?.play()
    }
    
    
    // Debug
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("connected: \(peerID.displayName)")
        case .connecting:
            print("connecting: \(peerID.displayName)")
        case .notConnected:
            print("not connected: \(peerID.displayName)")
            //self.state = .open
        }
    }
    
}

