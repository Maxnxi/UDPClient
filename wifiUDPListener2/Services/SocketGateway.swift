//
//  SocketGateway.swift
//  wifiUDPListener2
//
//  Created by Maksim on 12.09.2021.
//

import Foundation

public enum StateOfSocket {
    case readyToSend, pause, needToSendPreviousAgain, finish, finishWithError
}

class SocketGateway {
    
    //var isFinished: Bool = false
    //Pause Timer
    //var pauseTimer = Timer()
    var isPaused: Bool = false
    var countPauseSeconds = 0 {
        didSet {
            print("Pause Timer: ", countPauseSeconds)
            if countPauseSeconds == 3 && isPaused == true {
                stopPauseSendAgain()
            }
        }
    }
    //end
    
    //Counter of main loops // количество полных повторных загрузок = 1
    var inceptionCounter: Int = 0 {
        didSet {
            print("inceptionCounter didSet: ", inceptionCounter)
            if inceptionCounter == 2 {
                currentState = .finishWithError
            }
        }
    }
    //end
    
    var totalCountOfPackets: Int {
        didSet {
            print("Total Count setted")
        }
    }
    
    //счетчик ошибок
    let errorLimits: Int = 3    // предельный лимит ошибок (произвольно)
    var errorCounter: Int = 0 {
        didSet {
            print("Error counter didSet: ", errorCounter)
            if errorCounter == errorLimits{
                startInceptionAgain()
            }
        }
    }
    //номер пакета для отправки (из массива)
    var numberOfPacket: Int = 0
    var messageArr: [String]
    
    //Сокет
    let socket: SocketUDP?
    
    //статус сокета
    var currentState: StateOfSocket? {
        didSet {
            print("Change status", currentState as Any)
            //pauseTimer.invalidate()
            
            if currentState == .readyToSend {
                isPaused = false
                if numberOfPacket == totalCountOfPackets {
                    finishState()
                } else {
                    print("Ready To send")
                    send(nmbrPckt: numberOfPacket)
                }
            } else if currentState == .needToSendPreviousAgain {
                isPaused = false
                print("Send Again Previous")
                numberOfPacket -= 1
                errorCounter += 1
                send(nmbrPckt: numberOfPacket)
            } else if currentState == .pause {
                pause()
            } else if currentState == .finish {
                finish()
            } else if currentState == .finishWithError {
                finishWithError()
            }
        }
    }
    
    //main
    init(messageArr: [String]) {
        
        self.messageArr = messageArr
        self.totalCountOfPackets = messageArr.count
        
        socket = SocketUDP()

        print("Inited")
//        repeat {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//                if self.isFinished == true {
//                    completion()
//                }
//            }
//
//        } while isFinished == true
    }
    
    deinit {
        print("Object SocketGateway deinit")
    }
    
    func startSend(){
        currentState = .readyToSend
        socket?.socketDelegate = self
    }
    
    func send(nmbrPckt: Int) {
        if errorCounter == errorLimits {
            currentState = .finishWithError
        }
        socket?.connectSendMessageReceiveAnswer(message: messageArr[nmbrPckt])
    }
    
    func pause() {
        isPaused = true
        print("Pause")
        //startPauseTimer()
    }
    
    func stopPauseSendAgain() {
        currentState = .needToSendPreviousAgain
        errorCounter += 1
        isPaused = false
        //pauseTimer.invalidate()
    }
    
    func finishState() {
        currentState = .finish
    }
    
    func finish() {
        print("Finished sending Packs")
        socket?.closeSocket()
    }
    
    func finishWithError() {
        print("!!! Attention !!! Finish with error")
        socket?.closeSocket()
    }
    
//только один раз
    func startInceptionAgain() {
        errorCounter = 0
        inceptionCounter += 1
    }
    
}

extension SocketGateway: SocketUDPDelegate {
    func increaseErrorCounter() {
        self.errorCounter += 1
    }
    
    func changeStateofSocket(state: StateOfSocket) {
        self.currentState = state
    }
    
    func increasePacketNumber() {
        self.numberOfPacket += 1
    }
    
}

extension SocketGateway {
//    func startPauseTimer() {
//        //pauseTimer.invalidate()
//        countPauseSeconds = 0
//        //pauseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction(timer:)), userInfo: nil, repeats: true)
//        let timeQueue = DispatchQueue.init(label: "Timer")
//        timeQueue.sync {
//            repeat {
//                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
//                    DispatchQueue.main.async {
//                        self.countPauseSeconds += 1
//                        print("timer: ", self.countPauseSeconds)
//                    }
//                }
//            } while countPauseSeconds == 3
//        }
//        
//    }
    
//    @objc func timerAction(timer:Timer!) {
//        countPauseSeconds += 1
//    }
}
