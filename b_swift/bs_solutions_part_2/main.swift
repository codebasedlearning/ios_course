// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation


//----------------------


struct TodoItemS {
    let title: String
    var isCompleted: Bool

    mutating func markCompleted() {
        isCompleted = true
    }
}

class TodoItemC {
    let title: String
    var isCompleted: Bool

    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }

    func markCompleted() {
        isCompleted = true
    }
}

func theRustedIsland() {
    introduce(topic: "The Rusted Island")
    
    var todosS: [TodoItemS] = [
        TodoItemS(title: "Write Swift code", isCompleted: false),
        TodoItemS(title: "Debug the thing", isCompleted: false),
        TodoItemS(title: "Celebrate with coffee", isCompleted: false)
    ]

    todosS[0].markCompleted()

    print(" 1| todos (struct)")
    for todo in todosS {
        let status = todo.isCompleted ? "done" : "open"
        print(" a| - \(status): '\(todo.title)'")
    }
    print()

    let todosC = [
        TodoItemC(title: "Write Swift code"),
        TodoItemC(title: "Debug the thing"),
        TodoItemC(title: "Celebrate with coffee"),
    ]

    todosC.last!.markCompleted()

    print(" 2| todos (class)")
    for todo in todosC {
        let status = todo.isCompleted ? "done" : "open"
        print(" b| - \(status): '\(todo.title)'")
    }
}


//----------------------


protocol PaymentProtocol {
    var amount: Double { get }
    func authorize() -> Bool
    func completePayment() -> Bool
}

class Payment: PaymentProtocol {
    var amount: Double

    init(amount: Double) {
        self.amount = amount
    }

    func authorize() -> Bool {
        // basic authorization logic (could be overridden)
        print(" a|   Authorizing payment of \(amount)")
        return true
    }

    func completePayment() -> Bool {
        // basic payment completion logic (could be overridden)
        print(" b|   Completing payment of \(amount)")
        return true
    }
}

class CreditCardPayment: Payment {
    var creditCardNumber: String

    init(amount: Double, creditCardNumber: String) {
        self.creditCardNumber = creditCardNumber
        super.init(amount: amount)
    }

    override func authorize() -> Bool {
        // some specific authorization logic here
        print(" c|   Authorizing credit card payment of \(amount) for card \(creditCardNumber)")
        return true
    }
}

class PayPalPayment: Payment {
    var accountEmail: String

    init(amount: Double, accountEmail: String) {
        self.accountEmail = accountEmail
        super.init(amount: amount)
    }

    override func authorize() -> Bool {
        // some authorization logic here
        print(" d|   Authorizing PayPal payment of \(amount) for \(accountEmail)")
        return true
    }
}

func theBrokenVillage() {
    introduce(topic: "The Broken Village")
    
    let creditPayment = CreditCardPayment(amount: 120.00, creditCardNumber: "1234-5678-9101-1121")
    let paypalPayment = PayPalPayment(amount: 75.00, accountEmail: "bob@example.com")

    let payments: [Payment] = [creditPayment, paypalPayment]

    for payment in payments {
        if payment.authorize() {
            if payment.completePayment() {
                print(" 1| Payment processed successfully")
            } else {
                print(" 2| Failed to complete payment")
            }
        } else {
            print(" 3| Authorization failed")
        }
    }
}


//----------------------


extension Int {
    var roman: String? {
        guard self > 0 else { return nil } // Roman numerals are only positive

        let romanValues = [
            (1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
            (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
            (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")
        ]

        var result = ""
        var number = self

        for (value, romanSymbol) in romanValues {
            while number >= value {
                result += romanSymbol
                number -= value
            }
        }

        return result
    }
}

func theHarborOfExiles() {
    introduce(topic: "The Harbor of Exiles")
    
    if let roman = 1994.roman {
        print(" 1| Roman numeral for 1994 is \(roman)")
    }
    // more tests here...
}


//----------------------


class Queue<Element> {
    private var elements: [Element] = []

    func enqueue(_ element: Element) {
        elements.append(element)
    }

    func dequeue() -> Element? {
        guard !elements.isEmpty else { return nil }
        return elements.removeFirst()
    }

    func peek() -> Element? {
        elements.first
    }

    var isEmpty: Bool {
        elements.isEmpty
    }
}

// just a test
struct Person {
    var name: String
    var age: Int
}

func theTheAgonyLands() {
    introduce(topic: "The Agony Lands")

    let intQueue = Queue<Int>()
    intQueue.enqueue(10)
    intQueue.enqueue(20)
    assert(intQueue.peek() == 10)
    assert(intQueue.dequeue() == 10)
    assert(intQueue.dequeue() == 20)
    assert(intQueue.isEmpty)
    print(" 1| test intQueue passed!")
    
    let stringQueue = Queue<String>()
    stringQueue.enqueue("Hello")
    stringQueue.enqueue("World")
    // ...
    print(" 2| test stringQueue passed!")
    
    let personQueue = Queue<Person>()
    personQueue.enqueue(Person(name: "Alice", age: 30))
    personQueue.enqueue(Person(name: "Bob", age: 25))
    // ...
    print(" 3| test personQueue passed!")
}


//----------------------


theRustedIsland()
theBrokenVillage()
theHarborOfExiles()
theTheAgonyLands()


//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
