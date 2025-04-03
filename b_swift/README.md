[© 2025, A.Voß, FH Aachen, codebasedlearning.dev](mailto:info@codebasedlearning.dev)

# `swift_course`


## Motivation

> Finally, we want to build iOS apps for which we need swift. The language is very comprehensive and we want to focus on what we need for the apps first. So we'll start with a brief overview of a few small apps, and collect the features of the language. We will then look at them one by one.


## Topics 

We must at least discuss these subjects:
- comments
- var, let
- primitive types
- value and reference types
- collections, such as Array
- iterations
- functions and parameters
- functions as first-class citizens, closure variables or properties
- struct, class
- propeties, wrapper, getter, setter, backing fields, $-syntax
- lazy
- private, public
- member functions
- inheritance, protocol
- static
- enums
- trailing closure/lambda
- chaining
- guard
- ?-optionals, Nil-coalescing operator


## Tasks

### Part 1

> Create a macOS Command Line Tool (e.g. in 'New Project `MySolutions_PartI`') and single solution functions for each task or use an Online Swift Playground, e.g. https://swiftfiddle.com .

---

### 👉 Task 'The Whispering Island'

- Solve this task in a function called `theWhisperingIsland`.
- Read a text from the console,
- and convert it to an integer `n`.
- Print `n` to the console, e.g. "Your number was `n`". Use 'string interpolation'.
- Repeat this until you get an empty text.
- Protect your code appropriately with 'optional binding' and 'guards'.

Do you need exceptions?

Hint: `readLine() -> String?` returns a string read from standard input through the end of the current line.

---

### 👉 Task 'The Mountain of Silver'

- Solve this task in a function called `theMountainOfSilver`.
- Read a number `n` from the console, or pass `n` as a parameter if you know how to read,
- and calculate the n'th Fibonacci number, see [Fibonacci](https://de.wikipedia.org/wiki/Fibonacci-Folge).
  once in a loop and once with recursion.
- Add a caching system (called 'memoization') to the recursive computation, e.g. by using a dictionary containing already calculated Fibonacci numbers. 
- Use a 'guard' to throw an exception of your type, based on an `enum` derived from `Error`, if `n` is not positive.
- Test all different variants including the error and memoization-cases.

Hint: `n=35 -> fib(n)=9227465`

---

### 👉 Task 'The Doom Fields'

- Solve this task in a function called `theDoomFields`.
- Read a number `n` from the console, or pass `n` as a parameter, and calculate the sequence of numbers according to the Collatz conjecture, 
see [Collatz](https://de.wikipedia.org/wiki/Collatz-Problem).
- Use a list that you fill in one after the other and print it at the end.

Hint: `n=19 -> collatz=[19, 58, 29, 88, 44, 22, 11, 34, 17, 52, 26, 13, 40, 20, 10, 5, 16, 8, 4, 2, 1]`

---

### 👉 Task 'The Mist Labyrinth'

- Solve this task in a function called `theMistLabyrinth`.
- Write a function `findDigit` to find the first or the last digit in a parameter `line` of type string. A second parameter `fromStart` of type bool states whether you want to search from the start or from the end. Return an optional character which is the found character or `nil`.
- Write a function `findNumber`, which again takes a line and returns a combination of the first and last digit as a number (if found) or `0`. <br>
- Example, the values of these five lines are 34, 50, 0, 88, and 33:
```
3POeQx4
h5g6srvOA70N
abcdef
f8BMx7BgE8y
rLHp3jcN
```
- Put the text above in a raw string, split it into lines, call `findNumber` for each line and print the line and the result.

Hint: `c.isNumber` indicates whether a character `c` represents a number.

---

### 👉 Task 'The Harbor of Chaos'

- Solve this task in a function `theHarborOfChaos`.
- Assume the coefficients of a polynomial are stored in an array, e.g. `[1,2,3]` means `1+2x+3x^2`.
Write a function `apply` which receives an array (the polynomial) `p`, a value `x`, and a closure `m`, mapping Double to Double. It calculates `y=p(x)` using the [Horner scheme](https://de.wikipedia.org/wiki/Horner-Schema), and returns `m(y)`.
- Test `apply` with the polynomial above, `x=2.0` and `m:x->x^2`.

Hint: Consider `reduce`, and `m(p(2.0))=289.0`.

---

### Part 2

> Extend your project from Part I.

---

### 👉 Task 'The Broken Village'

Develop a flexible and extensible payment processing system. 
The system should accommodate various payment methods including credit cards, PayPal, and bank transfers. 

- Solve this task in a function `theBrokenVillage`.
- Define a `PaymentProtocol` that includes the following:
    - A member function `authorize` without parameters. It authorizes a payment and returns a boolean indicating success.
    - A member function `completePayment` without parameters. It completes the payment if authorization is successful and returns a boolean indicating success.
    - A read-only property `amount` of type `Double` to hold the amount to be paid.
- Create a base class `Payment` that implements `PaymentProtocol` and default behaviors for the methods declared in the protocol (print a message with the `amount`).
- Implement a subclass `CreditCardPayment` for handling credit card transactions. Add properties relevant to credit card payments, such as `creditCardNumber` and override one method.
- Implement a subclass `PayPalPayment` for handling payments through PayPal. Include properties specific to PayPal payments, such as `accountEmail` and override the other method.
- Create instances of each payment subclass, store them in a list and execute both payment processes traversing this list.

---

### 👉 Task 'The Harbor of Exiles'

Implement a Swift extension that converts an integer to its corresponding Roman numeral representation.

- Solve this task in a function `theHarborOfExiles`.
- Extend the `Int` type with a computed property `roman` that returns the Roman numeral equivalent as a `String?`.
- The Roman numeral should only be computed for positive integers. Return `nil` for zero or negative integers.
- Ensure the conversion adheres to the rules of Roman numerals:
    - Symbols include I (1), V (5), X (10), L (50), C (100), D (500), M (1000).
    - Implement rules for subtractive notation such as IV (4), IX (9), etc.
- Test the extension with a range of numbers to ensure accurate conversion.
Include edge cases such as very small numbers, relatively large numbers, and invalid inputs like zero or negative numbers.

---

### 👉 Task 'The Agony Lands'

Develop a generic Queue class that can handle any data type. The queue should support basic operations such as enqueue, dequeue, and peek.

- Solve this task in a function `theAgonyLands`.
- Implement a generic class `Queue` where the type of elements it holds is unspecified until an instance is created. The queue should be able to store elements of any given type. Implement these Queue Operations:
    - `enqueue`: Add an element to the back of the queue.
    - `dequeue`: Remove the element at the front of the queue and return it. If the queue is empty, return `nil`.
    - `peek`: Return the element at the front of the queue without removing it. If the queue is empty, return `nil`.
    - `isEmpty`: A property or method that returns a boolean indicating whether the queue is empty.
- Use an array to store the elements of the queue. Ensure that the queue operations are as efficient as possible, considering the underlying array's performance characteristics.
- Create instances of the queue with different data types, e.g., `Int`, `String`, and a custom `struct` or `class`. Perform a series of operations to demonstrate that the queue handles enqueuing, dequeuing, and peeking correctly.
Test edge cases such as dequeueing from an empty queue.

---

### 👉 Task 'Couch Potato' - Recurring homework.

- If you have not completed the main tasks in the exercise, complete them at home.

---


End of `Tasks`

