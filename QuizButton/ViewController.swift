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
    
    

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var resultText: UILabel!
    @IBOutlet weak var diffText: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    var condition = Condition.clear
    
    var userTime = Date()
    var opponentTime = Date()
    
    var count = 0
    
    var peerId: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
            var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        condition = .clear
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupConnectivity()
    }
    
    func setupConnectivity() {
        peerId = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("connected: \(peerID.displayName)")
        case .connecting:
            print("connecting: \(peerID.displayName)")
        case .notConnected:
            print("not connected: \(peerID.displayName)")
        }
    }
    
    @IBAction func addCounter(_ sender: Any) {
        count += 10
        countLabel.text = String(count)
    }
    @IBAction func subtractCounter(_ sender: Any) {
        count -= 10
        countLabel.text = String(count)
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let time = String(data: data, encoding: .utf8)//try JSONDecoder().decode(String.self, from: data)
            if time == "youwon" {
                DispatchQueue.main.async { self.resultText.text = "YOU WIN" }
                condition = .done
                DispatchQueue.main.async { self.view.backgroundColor = .red }
                var fileURL = Bundle.main.path(forResource: "quizsound", ofType: "m4a")!
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                audioPlayer?.play()
                let generator = UINotificationFeedbackGenerator()
                DispatchQueue.main.async { generator.notificationOccurred(.success) }
                return
            }
            if self.condition == .judging { //すでに自分は押している
                opponentTime = dateFromString(string: time!, format: "y-MM-dd H:m:ss.SSSS")
                print("my")
                print(stringFromDate(date: userTime, format: "y-MM-dd H:m:ss.SSSS"))
                print("oppo")
                print(stringFromDate(date: opponentTime, format: "y-MM-dd H:m:ss.SSSS"))
                condition = .done
                let diff = Calendar.current.dateComponents([.second], from: opponentTime, to: userTime)
                let nanodiff = Calendar.current.dateComponents([.nanosecond], from: opponentTime, to: userTime)
                
                DispatchQueue.main.async { self.diffText.text = String(fabs(Double(nanodiff.nanosecond!)/1000000000)) + "sec." }
                if opponentTime < userTime {
                    DispatchQueue.main.async { self.resultText.text = "YOU LOSE" }
                    DispatchQueue.main.async { self.view.backgroundColor = .blue }
                } else {
                    DispatchQueue.main.async { self.resultText.text = "YOU WIN" }
                    DispatchQueue.main.async { self.view.backgroundColor = .red }
                    var fileURL = Bundle.main.path(forResource: "quizsound", ofType: "m4a")!
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                    audioPlayer?.play()
                    let generator = UINotificationFeedbackGenerator()
                    DispatchQueue.main.async { generator.notificationOccurred(.success) }
                }
            } else {
                DispatchQueue.main.async { self.resultText.text = "YOU LOSE" }
                condition = .done
                DispatchQueue.main.async { self.view.backgroundColor = .blue }
                do {
                    try mcSession.send(("youwon").data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    print("hoo")
                }
            }
            print(time)
            
        } catch {
            print("oops")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }

    @IBAction func ConnectButtonTapped(_ sender: Any) {
        let actionSheet = UIAlertController(title: "ToDo Exchange", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ba-td", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "ba-td", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.sourceView = self.view
        
        let screenSize = UIScreen.main.bounds
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height/2, width: 0, height: 0)
        actionSheet.popoverPresentationController?.permittedArrowDirections = []
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func sendTime(_ time: Date) {
        userTime = time
        if self.condition == .judging { //すでに相手は押している
            if opponentTime < userTime {
                DispatchQueue.main.async { self.resultText.text = "YOU LOSE" }
                DispatchQueue.main.async { self.view.backgroundColor = .blue }
            } else {
                DispatchQueue.main.async { self.resultText.text = "YOU WIN" }
                DispatchQueue.main.async { self.view.backgroundColor = .red }
                var fileURL = Bundle.main.path(forResource: "quizsound", ofType: "m4a")!
                audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                audioPlayer?.play()
                let generator = UINotificationFeedbackGenerator()
                DispatchQueue.main.async { generator.notificationOccurred(.success) }
            }
            condition = .done
            let diff = Calendar.current.dateComponents([.second], from: opponentTime, to: userTime)
            let nanodiff = Calendar.current.dateComponents([.nanosecond], from: opponentTime, to: userTime)
            
            DispatchQueue.main.async { self.diffText.text = String(fabs(Double(nanodiff.nanosecond!)/1000000000)) + "sec." }
        }
        print("send")
        condition = .judging
        resultText.text = "Judging..."
        if mcSession.connectedPeers.count > 0 {
            let timeString = stringFromDate(date: time, format: "y-MM-dd H:m:ss.SSSS")
            print(timeString)
            print(dateFromString(string: timeString, format: "y-MM-dd H:m:ss.SSSS"))
            do {
                try mcSession.send(timeString.data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
               print("hoo")
            }
        }  else {
            print("oops2")
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        print("hi")
        if condition == .clear {
            sendTime(Date())
        }
    }
    @IBAction func buttonTouchDowned(_ sender: Any) {
        button.imageView?.image = UIImage(named: "button2")
    }
    @IBAction func buttonTouchUped(_ sender: Any) {
        button.imageView?.image = UIImage(named: "button1")
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
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
        resultText.text = ""
        diffText.text = ""
        condition = .clear
        view.backgroundColor = UIColor(red:0.12, green:0.13, blue:0.14, alpha:1.0)
        userTime = Date()
        opponentTime = Date()
    }
    
    enum Condition {
        case clear
        case done
        case judging
    }
}

