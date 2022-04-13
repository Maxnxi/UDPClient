//
//  SocketUDP2Broadcast.swift
//  wifiUDPListener2
//
//  Created by Maksim on 13.09.2021.
//

import Foundation
import Network



class SocketUDP2 {
    
    var connection: NWConnection?
    var hostUDP: NWEndpoint.Host = "255.255.255.255"
    var portUDP: NWEndpoint.Port = 9090
        
        //MARK:- UDP
    init() {
        
//        let params = NWParameters(dtls: nil, udp: .init())
//        params.requiredLocalEndpoint = NWEndpoint.hostPort(host: .ipv4(.any), port: 9001)
//        self.connection = NWConnection(host: hostUDP, port: portUDP, using: params)
    }
          
    public func connectSendMessageReceiveAnswer(message: String) {
              // Transmited message:
              self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)
              self.connection?.stateUpdateHandler = { (newState) in
                  print("This is stateUpdateHandler:")
                  switch (newState) {
                      case .ready:
                        print("State: Ready\n")
                        self.sendUDP(message: message)
                        self.receiveUDP()
                        sleep(1)
                      case .setup:
                          print("State: Setup\n")
                      case .cancelled:
                          print("State: Cancelled\n")
                      case .preparing:
                          print("State: Preparing\n")
                      default:
                          print("ERROR! State not defined!\n")
                  }
              }
              self.connection?.start(queue: .global())
        
          }

    //sub functions
       private func sendUDP(message: String) {
            guard let contentToSendUDP = message.hexadecimal else {
                print("Error in converting")
                return
            }
//            print("Data to send", contentToSendUDP as Any)
            connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed({ error in
                if error == nil {
                    
                    print("Send succeded")
                    
                    //self.numberOfPacket += 1
                } else {
                    print("Error while sending udp packet", error)
                    
                }
                
            }) )
          }

          private func receiveUDP() {
              self.connection?.receiveMessage { (data, context, isComplete, error) in
                if (isComplete) {
                    guard let stringHex = data?.hexadecimal else { return }
                    print("Receive is complete", stringHex)
                    DecodeLib.shared.parseBinAndReturnView(string: stringHex)
                    
                } else if (isComplete == false && error != nil) {
                    print("Error in receive")
                }
              }
          }
        

    
}
