// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation


//----------------------


func theWhisperingIsland(simulateInput: Bool = true) {
    introduce(topic: "The Whispering Island")
    
    guard !simulateInput else {
        let n = 23
        print(" 1| Your simulated number was \(n).")
        return
    }
    
    while true {
        print(" 1| Enter a number (or press Enter to exit): ", terminator: "")
        
        guard let line = readLine(), !line.isEmpty else {
            print(" 2| No input...Exiting.")
            break
        }
        
        if let n = Int(line) {
            print(" 3| Your number was \(n).")
        } else {
            print(" 4| Error: Your input '\(line)' is not a valid integer.")
        }
    }
}


//----------------------


enum ParameterError: Error {
    case outOfRange(String)
}

func fibonacciLoop(n: Int) throws -> Int {
    guard n>=1 else { throw ParameterError.outOfRange("'n' must be positive (was \(n)).") }
    guard n>1 else { return 1 }

    var (a, b) = (0, 1)
    for _ in 2...n {
        (a, b) = (b, a+b)
    }
    return b
}

func fibonacciRecursion(n: Int) throws -> Int {
    guard n>=1 else { throw ParameterError.outOfRange("'n' must be positive (was \(n)).") }

    var cache: [Int: Int] = [0: 0, 1: 1]                            // fib(0) = 0, fib(1) = 1

    func f(_ n: Int) -> Int {
        if let result = cache[n] {
            return result
        }
        
        let value = f(n-1) + f(n-2)                                 // return n<=1 ? n : f(n-1) + f(n-2)
        cache[n] = value
        return value
    }
    
    return f(n)
}

func theMountainOfSilver(n: Int = 35) {
    introduce(topic: "The Mountain of Silver")

    do {
        let n1 = try fibonacciLoop(n: n)
        let n2 = try fibonacciRecursion(n: n)
        print(" 1| n=\(n), fib_v1=\(n1), fib_v2=\(n2)")
        
        let n3 = try fibonacciRecursion(n: 0)
        print("... never \(n3)")
    } catch ParameterError.outOfRange(let message) {
        print(" 2| Error: \(message)")
    } catch {
        print(" 3| Unexpected Error: \(error)")
    }
}


//----------------------


func theDoomFields(n: Int = 19) {
    introduce(topic: "The Doom Fields")

    var sequence = [n]
    var current = n

    while current != 1 {
        current = current % 2 == 0 ? current / 2 : 3 * current + 1
        sequence.append(current)
    }

    print(" 1| n=\(n), sequence=\(sequence)")
}


//----------------------


func findDigit(line: String, fromStart: Bool) -> Character? {
    return fromStart ? line.first { $0.isNumber } : line.reversed().first { $0.isNumber }
}

func findNumber(line: String) -> Int {
    let firstDigit = findDigit(line: line, fromStart: true)
    let lastDigit = findDigit(line: line, fromStart: false)

    return if let first = firstDigit, let last = lastDigit {
         Int(String([first, last])) ?? 0
    } else {
         0
    }
}

func theMistLabyrinth() {
    introduce(topic: "The Mist Labyrinth")

    let rawString = """
    3POeQx4
    h5g6srvOA70N
    abcdef
    f8BMx7BgE8y
    rLHp3jcN
    """

    let lines = rawString.split(separator: "\n")
    for line in lines {
        let result = findNumber(line: String(line))
        print(" 1| '\(line)' -> \(result)")
    }
}


//----------------------


func theHarborOfChaos() {
    introduce(topic: "The Harbor of Chaos")
 
    func apply(p: [Int], x: Double, m: (Double) -> Double) -> Double {
        // Horner's method
        let y = p.reversed().reduce(0.0) { (result, coeff) -> Double in
            return result * x + Double(coeff)
        }
        return m(y)
    }

    let polynomial = [1, 2, 3] // represents 1 + 2x + 3x^2
    let x = 2.0
    let result = apply(p: polynomial, x: x) { $0*$0 }
    
    print(" 1| m(p(\(x)))=\(result)")
}


//----------------------


theWhisperingIsland()
theMountainOfSilver()
theDoomFields()
theMistLabyrinth()
theHarborOfChaos()


//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
