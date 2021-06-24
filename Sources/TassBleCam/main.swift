import SwiftyGPIO //Remove this import if you are compiling manually with switfc
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import Foundation
import SG90Servo


let uarts = SwiftyGPIO.UARTs(for: .RaspberryPiPlusZero)
let pwms = SwiftyGPIO.hardwarePWMs(for: .RaspberryPiPlusZero)
//var uart = uarts[0]

guard let uart = uarts?.first, let pwmFirst = (pwms?[0]), let pwm = pwmFirst[.P18]
else {
  exit(0)
}

let s1 = SG90Servo(pwm)
s1.enable()
uart.configureInterface(speed: .S9600, bitsPerChar: .Eight, stopBits: .One, parity: .None)

print("Ready...")

if #available(macOS 10.12, *) {
  let tRead = Thread() {
    while true {
      let s = uart.readString()
      if s != "" {
        print("Echo: "+s, terminator: "")
      }
      
      if let value = Int(s) {
        switch value {
          case 0...60:
            s1.move(to: .left)
          case 61...120:
            s1.move(to: .middle)
          case 121...180:
            s1.move(to: .right)
          default:
            s1.move(to: .left)
        }
        
      }
    }
  }
  
  
  tRead.start()
  
  DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//    let temp1 = UInt8(10)
    let temp2 = CChar(10)
    uart.writeData([temp2])
  }
  
  var exit = false
  
  while (!exit) {
    let readText = uart.readLine()
    if !readText.isEmpty {
      print("text: ", readText)
    }
    //
    //  if readText.contains("exit") {
    //    exit = true
    //    break
    //  }
    
    print("Send: ", terminator: " ")
    let input = readLine(strippingNewline: false)
    exit = (input == "exit\n")
    
    if !exit {
      uart.writeString(input ?? "inputErr")
    }
    
  }
}

