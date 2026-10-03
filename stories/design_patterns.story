{
  "name": "Introduction to Design Patterns",
  "description": "What design patterns are, the principles behind them, and six GoF patterns (Singleton, Factory Method, Adapter, Decorator, Strategy, Observer) with UML diagrams and Java code. Every diagram is Mermaid, so the deck doubles as a test of the beautiful-mermaid renderer.",
  "navigation": {
    "show": true,
    "style": "arrows-name",
    "position": "top-right",
    "showNumber": true
  },
  "sequenceArrows": {
    "show": true,
    "style": "dashed",
    "color": "#ffcc00",
    "alpha": 0.75
  },
  "nodes": [
    {
      "name": "Start",
      "x": 0,
      "y": 0,
      "text": "<!-- _class: lead -->\n\n# Design Patterns\n\n### An introduction, with UML and Java\n\nReusable solutions to design problems that keep coming back\n\n<!--\nSpeaker note: every diagram in this deck is Mermaid, drawn by beautiful-mermaid, so it doubles as a test of what that renderer can do.\n-->\n"
    },
    {
      "name": "What-Is-A-Pattern",
      "x": 240,
      "y": 0,
      "text": "# What is a design pattern?\n\n> Each pattern describes a problem which occurs over and over again in our environment, and then describes the core of the solution to that problem, in such a way that you can use this solution a million times over, without ever doing it the same way twice.\n>\n> — Christopher Alexander, *A Pattern Language* (1977)\n\nIn 1994 the **Gang of Four** (Gamma, Helm, Johnson and Vlissides) applied the idea to object-oriented software and catalogued **23 patterns**. Each one has four parts:\n\n| Part | The question it answers |\n|---|---|\n| **Name** | What do we call it, so we can talk about it? |\n| **Problem** | When does it apply? |\n| **Solution** | Which classes and objects, and how do they collaborate? |\n| **Consequences** | What does it cost, and what do we gain? |\n\n<style scoped>section { font-size: 24px; } blockquote { font-size: 0.85em; } p { margin: 0.5em 0; }</style>\n"
    },
    {
      "name": "Why-Learn-Them",
      "x": 480,
      "y": 0,
      "text": "# Why learn them?\n\n**What you gain**\n\n- **A shared vocabulary.** “Make the pricing a Strategy” says in four words what would otherwise take a paragraph.\n- **Designs that have been tested.** Each pattern has been refined across many systems and many teams.\n- **Room to change.** Most patterns fence off the part of a design that is likely to change.\n- **Faster code reading.** Recognise the shape, and you know the intent before you read every line.\n\n**What to watch for**\n\n- A pattern is a *shape* to adapt, not code to paste.\n- Every pattern adds indirection. Use one when the problem is actually there, not in case it turns up.\n- Modern Java (lambdas, enums, records) makes several patterns much lighter than they were in 1994.\n\n<style scoped>section { font-size: 25px; } p { margin: 0.5em 0 0.1em; } ul { margin-top: 0; }</style>\n"
    },
    {
      "name": "Reading-UML",
      "x": 720,
      "y": 0,
      "text": "# Reading a UML class diagram\n\n```mermaid\nclassDiagram\n    class Shape {\n       <<interface>>\n        +area() double\n    }\n\n    class Counter {\n        -int total$\n        +increment() void\n    }\n    Shape <|.. Circle : implements\n    Animal <|-- Dog : extends\n```\n\n| Line and end | Meaning | In Java |\n|---|---|---|\n| solid, hollow triangle | inheritance | `extends` |\n| dotted, hollow triangle | realisation | `implements` |\n| `+` `-` `#` | visibility | public, private, protected |\n| underlined member | static | `static` |\n\n<style scoped>\nsection { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); grid-template-rows: auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1 { grid-column: 1 / -1; margin: 0 0 0.3em; }\np { margin: 0; align-self: center; }\np svg { max-height: 500px; }\ntable { font-size: 0.72em; align-self: center; }\n</style>\n"
    },
    {
      "name": "Reading-UML 2",
      "x": 600,
      "y": 0,
      "text": "# Reading a UML class diagram\n\n```mermaid\nclassDiagram\n    Order ..> Printer : uses\n    Lecturer -- Office : association\n    Driver --> Car : association (navigable)\n\n\n```\n\n| Line and end | Meaning | In Java |\n|---|---|---|\n| dotted, open arrow | dependency: **uses** | a parameter or local |\n| solid, no ends | association: know about each other | a field (either side) |\n| solid, open arrow | association: knows about <br> (can navigate to) | a field |\n\n<style scoped>\nsection { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); grid-template-rows: auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1 { grid-column: 1 / -1; margin: 0 0 0.3em; }\np { margin: 0; align-self: center; }\np svg { max-height: 500px; }\ntable { font-size: 0.72em; align-self: center; }\npolyline[data-from='Lecturer'][data-to='Office'] { marker-end: none; }\n</style>\n"
    },
    {
      "name": "Reading UML 3",
      "x": 40,
      "y": 40,
      "text": "# Reading a UML class diagram: don’t worry about these 2\n\n```mermaid\nclassDiagram\n    Team o-- Player : aggregation\n    Team *-- Player : composition\n```\n\n| Line and end | Meaning | In Java |\n|---|---|---|\n| hollow diamond | aggregation: has, shared | a field |\n| filled diamond | composition: owns, same lifetime | a field it creates |\n\n<style scoped>\nsection { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); grid-template-rows: auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1 { grid-column: 1 / -1; margin: 0 0 0.3em; }\np { margin: 0; align-self: center; }\np svg { max-height: 500px; }\ntable { font-size: 0.72em; align-self: center; }\n</style>\n"
    },
    {
      "name": "Design-Principles",
      "x": 720,
      "y": 140,
      "text": "# Three principles behind (almost) every pattern\n\n1. **Program to an interface, not an implementation.** Callers depend on `List`, not `ArrayList`, so the implementation can change under them.\n2. **Favour composition over inheritance.** A `Report` *has* a `Formatter`, instead of there being a subclass for every format.\n3. **Encapsulate what varies.** The part that is likely to change sits behind one interface, so change stays in one place.\n\n```java\n// 1. Depend on the abstraction, not the concrete class\nList<String> names = new ArrayList<>();\n\n// 3. The part that varies (the format) lives behind one interface\ninterface Formatter {\n    String format(Report report);\n}\n\n// 2. Report HAS a Formatter, rather than BEING an HtmlReport or a CsvReport\nclass Report {\n    private final Formatter formatter;\n\n    Report(Formatter formatter) {\n        this.formatter = formatter;   // swap it without touching Report\n    }\n\n    String render() {\n        return formatter.format(this);\n    }\n}\n```\n\n<style scoped>\nsection { display: grid; grid-template-columns: 4fr 6fr; grid-template-rows: auto 1fr; column-gap: 28px; align-content: start; font-size: 21px; }\nh1 { grid-column: 1 / -1; margin: 0 0 0.3em; }\nol { margin: 0; align-self: center; }\nli { margin-bottom: 0.3em; }\npre { font-size: 0.7em; margin: 0; align-self: center; }\n</style>\n"
    },
    {
      "name": "Pattern-Families",
      "x": 480,
      "y": 140,
      "text": "# The three families\n\n```mermaid\nflowchart LR\n    P([The 23 GoF patterns]) --> C[Creational (5)]\n    P --> S[Structural (7)]\n    P --> B[Behavioural (11)]\n    classDef today fill:#fff3c4,stroke:#e0a800,stroke-width:3px\n```\n"
    },
    {
      "name": "Creational",
      "x": 560,
      "y": 540,
      "text": "# The three families\n\n\n```mermaid\nflowchart LR\n    C[Creational]\n    C --> FM[Factory Method]:::today\n    C --> CX[Singleton , Builder, Abstract Factory, Prototype]\n    classDef today fill:#fff3c4,stroke:#e0a800,stroke-width:3px\n```\n\n**Creational** patterns control how objects are made, **structural** ones how objects are composed, and **behavioural** ones how objects share work. The six highlighted are covered in this deck.\n\n<style scoped>section { font-size: 22px; } p { margin: 0.3em 0; } p svg { max-height: 440px; }</style>\n"
    },
    {
      "name": "Structural",
      "x": 600,
      "y": 580,
      "text": "# The three families\n\n\n```mermaid\nflowchart LR\n    S[Structural]\n    S --> Adapter:::today\n    S --> Decorator:::today\n    S --> SX[Bridge, Composite, Facade, Flyweight, Proxy]\n    classDef today fill:#fff3c4,stroke:#e0a800,stroke-width:3px\n```\n\n**Creational** patterns control how objects are made, **structural** ones how objects are composed, and **behavioural** ones how objects share work. The six highlighted are covered in this deck.\n\n<style scoped>section { font-size: 22px; } p { margin: 0.3em 0; } p svg { max-height: 440px; }</style>\n"
    },
    {
      "name": "Behavioural",
      "x": 640,
      "y": 620,
      "text": "# The three families\n\n\n```mermaid\nflowchart LR\n    B[Behavioural]\n    B --> Strategy:::today\n    B --> Observer:::today\n    B --> BX[Command, Iterator, State, Visitor, and 5 more]\n    classDef today fill:#fff3c4,stroke:#e0a800,stroke-width:3px\n```\n\n**Creational** patterns control how objects are made, **structural** ones how objects are composed, and **behavioural** ones how objects share work. The six highlighted are covered in this deck.\n\n<style scoped>section { font-size: 22px; } p { margin: 0.3em 0; } p svg { max-height: 440px; }</style>\n"
    },
    {
      "name": "Singleton",
      "x": 240,
      "y": 140,
      "text": "# Singleton · creational\n\n> **Intent:** ensure a class has only one instance, and give everyone a single point of access to it.\n> **Use sparingly:** a singleton is global state in disguise. It hides dependencies and makes testing harder.\n\n```mermaid\nclassDiagram\n    class Configuration {\n        -Configuration INSTANCE$\n        -Map<String,String> settings\n        -Configuration()\n        +getInstance() Configuration\n        +get(String key) String\n    }\n    class Client\n    Client ..> Configuration : getInstance()\n```\n\n```java\npublic final class Configuration {\n    private static final Configuration INSTANCE = new Configuration();\n\n    private final Map<String, String> settings = new HashMap<>();\n\n    private Configuration() {          // nobody else can call new\n        settings.put(\"theme\", \"dark\");\n    }\n\n    public static Configuration getInstance() {\n        return INSTANCE;\n    }\n\n    public String get(String key) {\n        return settings.get(key);\n    }\n}\n\n// Anywhere in the program\nString theme = Configuration.getInstance().get(\"theme\");\n```\n\n<style scoped>\nsection { display: grid; grid-template-columns: 5fr 6fr; grid-template-rows: auto auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1, blockquote { grid-column: 1 / -1; }\nh1 { margin: 0 0 0.2em; }\nblockquote { margin: 0 0 0.5em; font-size: 0.9em; }\np { margin: 0; align-self: center; }\np svg { max-height: 400px; }\npre { font-size: 0.66em; margin: 0; align-self: start; }\n</style>\n"
    },
    {
      "name": "Factory-Method",
      "x": 0,
      "y": 140,
      "text": "# Factory Method · creational\n\n> **Intent:** define an interface for creating an object, but let subclasses decide which class to instantiate.\n\n```mermaid\nclassDiagram\n    class Dialog {\n        <<abstract>>\n        +render() void\n        #createButton() Button\n        #close() void\n    }\n    class WindowsDialog {\n        #createButton() Button\n    }\n    class WebDialog {\n        #createButton() Button\n    }\n    class Button {\n        <<interface>>\n        +paint() void\n        +onClick(Runnable action) void\n    }\n    class WindowsButton\n    class HtmlButton\n    Dialog <|-- WindowsDialog\n    Dialog <|-- WebDialog\n    Button <|.. WindowsButton\n    Button <|.. HtmlButton\n    Dialog ..> Button : uses\n    WindowsDialog ..> WindowsButton : creates\n    WebDialog ..> HtmlButton : creates\n```\n\n```java\npublic interface Button {\n    void paint();\n    void onClick(Runnable action);\n}\n\npublic abstract class Dialog {\n    // The factory method: each subclass decides which Button to make\n    protected abstract Button createButton();\n\n    public void render() {\n        Button ok = createButton();   // no concrete class named here\n        ok.onClick(this::close);\n        ok.paint();\n    }\n\n    protected void close() { }\n}\n\npublic class WebDialog extends Dialog {\n    @Override\n    protected Button createButton() {\n        return new HtmlButton();\n    }\n}\n```\n\n<style scoped>\nsection { display: grid; grid-template-columns: 5fr 6fr; grid-template-rows: auto auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1, blockquote { grid-column: 1 / -1; }\nh1 { margin: 0 0 0.2em; }\nblockquote { margin: 0 0 0.5em; font-size: 0.9em; }\np { margin: 0; align-self: center; }\np svg { max-height: 460px; }\npre { font-size: 0.66em; margin: 0; align-self: start; }\n</style>\n"
    },
    {
      "name": "Adapter",
      "x": 0,
      "y": 280,
      "text": "# Adapter · structural\n\n> **Intent:** convert the interface of a class into the one its clients expect, so classes that couldn't otherwise work together can.\n\n```mermaid\nclassDiagram\n    class Checkout\n    class PaymentProcessor {\n        <<interface>>\n        +pay(long cents) void\n    }\n    class GatewayAdapter {\n        -LegacyGateway gateway\n        +pay(long cents) void\n    }\n    class LegacyGateway {\n        +makePayment(double amount, String currency) void\n    }\n    Checkout --> PaymentProcessor : pays through\n    GatewayAdapter ..|> PaymentProcessor\n    GatewayAdapter --> LegacyGateway : delegates to\n```\n\n```java\n// What our code expects\npublic interface PaymentProcessor {\n    void pay(long cents);\n}\n\n// A third-party class we can't change, with the \"wrong\" interface\npublic class LegacyGateway {\n    public void makePayment(double amount, String currency) { /* ... */ }\n}\n\n// The adapter: looks like a PaymentProcessor, talks to a LegacyGateway\npublic class GatewayAdapter implements PaymentProcessor {\n    private final LegacyGateway gateway;\n\n    public GatewayAdapter(LegacyGateway gateway) {\n        this.gateway = gateway;\n    }\n\n    @Override\n    public void pay(long cents) {\n        gateway.makePayment(cents / 100.0, \"EUR\");   // translate the call\n    }\n}\n\nPaymentProcessor payments = new GatewayAdapter(new LegacyGateway());\n```\n\n<style scoped>\nsection { display: grid; grid-template-columns: 5fr 6fr; grid-template-rows: auto auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1, blockquote { grid-column: 1 / -1; }\nh1 { margin: 0 0 0.2em; }\nblockquote { margin: 0 0 0.5em; font-size: 0.9em; }\np { margin: 0; align-self: center; }\np svg { max-height: 460px; }\npre { font-size: 0.66em; margin: 0; align-self: start; }\n</style>\n"
    },
    {
      "name": "Decorator",
      "x": 240,
      "y": 280,
      "text": "# Decorator · structural\n\n> **Intent:** attach extra responsibilities to an object at run time, as a flexible alternative to subclassing. `java.io` works this way: `new BufferedReader(new InputStreamReader(in))`.\n\n```mermaid\nclassDiagram\n    class Coffee {\n        <<interface>>\n        +cost() double\n        +description() String\n    }\n    class Espresso {\n        +cost() double\n        +description() String\n    }\n    class CoffeeDecorator {\n        <<abstract>>\n        #Coffee inner\n        +cost() double\n        +description() String\n    }\n    class Milk\n    class Caramel\n    Coffee <|.. Espresso\n    Coffee <|.. CoffeeDecorator\n    Coffee --o CoffeeDecorator : wraps\n    CoffeeDecorator <|-- Milk\n    CoffeeDecorator <|-- Caramel\n```\n\n```java\npublic abstract class CoffeeDecorator implements Coffee {\n    protected final Coffee inner;\n\n    protected CoffeeDecorator(Coffee inner) { this.inner = inner; }\n\n    public double cost() { return inner.cost(); }\n    public String description() { return inner.description(); }\n}\n\npublic class Milk extends CoffeeDecorator {\n    public Milk(Coffee inner) { super(inner); }\n\n    @Override\n    public double cost() { return inner.cost() + 0.50; }\n\n    @Override\n    public String description() { return inner.description() + \", milk\"; }\n}\n\n// Caramel is written the same way. Wrap at run time, in any combination:\nCoffee order = new Caramel(new Milk(new Espresso()));\nSystem.out.println(order.description());   // Espresso, milk, caramel\n```\n\n<style scoped>\nsection { display: grid; grid-template-columns: 5fr 6fr; grid-template-rows: auto auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1, blockquote { grid-column: 1 / -1; }\nh1 { margin: 0 0 0.2em; }\nblockquote { margin: 0 0 0.5em; font-size: 0.9em; }\np { margin: 0; align-self: center; }\np svg { max-height: 440px; }\npre { font-size: 0.66em; margin: 0; align-self: start; }\n</style>\n"
    },
    {
      "name": "Strategy",
      "x": 480,
      "y": 280,
      "text": "# Strategy · behavioural\n\n> **Intent:** define a family of algorithms, put each in its own class, and make them interchangeable. The code that uses one doesn't care which.\n\n```mermaid\nclassDiagram\n    class ShoppingCart {\n        -List<Double> prices\n        -DiscountStrategy discount\n        +add(double price) void\n        +setDiscount(DiscountStrategy d) void\n        +total() double\n    }\n    class DiscountStrategy {\n        <<interface>>\n        +apply(double subtotal) double\n    }\n    class PercentOff {\n        -double percent\n    }\n    class FixedAmountOff {\n        -double amount\n    }\n    ShoppingCart o-- DiscountStrategy\n    DiscountStrategy <|.. PercentOff\n    DiscountStrategy <|.. FixedAmountOff\n```\n\n```java\n@FunctionalInterface\npublic interface DiscountStrategy {\n    double apply(double subtotal);\n}\n\npublic class PercentOff implements DiscountStrategy {\n    private final double percent;\n    public PercentOff(double percent) { this.percent = percent; }\n    public double apply(double subtotal) {\n        return subtotal * (1 - percent / 100);\n    }\n}\n\npublic class ShoppingCart {\n    private final List<Double> prices = new ArrayList<>();\n    private DiscountStrategy discount = subtotal -> subtotal;   // no discount\n\n    public void add(double price) { prices.add(price); }\n    public void setDiscount(DiscountStrategy d) { discount = d; }\n\n    public double total() {\n        double subtotal = prices.stream().mapToDouble(p -> p).sum();\n        return discount.apply(subtotal);\n    }\n}\n\ncart.setDiscount(new PercentOff(10));\ncart.setDiscount(s -> s > 100 ? s - 20 : s);   // a lambda is a strategy too\n```\n\n<style scoped>\nsection { display: grid; grid-template-columns: 5fr 6fr; grid-template-rows: auto auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1, blockquote { grid-column: 1 / -1; }\nh1 { margin: 0 0 0.2em; }\nblockquote { margin: 0 0 0.5em; font-size: 0.9em; }\np { margin: 0; align-self: center; }\np svg { max-height: 440px; }\npre { font-size: 0.64em; margin: 0; align-self: start; }\n</style>\n"
    },
    {
      "name": "Observer",
      "x": 720,
      "y": 280,
      "text": "# Observer · behavioural\n\n> **Intent:** define a one-to-many dependency, so that when one object changes state, all its dependents are notified automatically.\n\n```mermaid\nclassDiagram\n    class WeatherStation {\n        -List<WeatherListener> listeners\n        +subscribe(WeatherListener l) void\n        +unsubscribe(WeatherListener l) void\n        +setTemperature(double celsius) void\n    }\n    class WeatherListener {\n        <<interface>>\n        +onTemperature(double celsius) void\n    }\n    class Display\n    class PhoneApp\n    WeatherStation \"1\" o-- \"*\" WeatherListener : notifies\n    WeatherListener <|.. Display\n    WeatherListener <|.. PhoneApp\n```\n\n```java\npublic interface WeatherListener {\n    void onTemperature(double celsius);\n}\n\npublic class WeatherStation {\n    private final List<WeatherListener> listeners = new ArrayList<>();\n\n    public void subscribe(WeatherListener l)   { listeners.add(l); }\n    public void unsubscribe(WeatherListener l) { listeners.remove(l); }\n\n    public void setTemperature(double celsius) {\n        // Loop over a copy, so a listener can unsubscribe while being told\n        for (WeatherListener l : List.copyOf(listeners)) {\n            l.onTemperature(celsius);\n        }\n    }\n}\n\nWeatherStation station = new WeatherStation();\nstation.subscribe(new Display());\nstation.subscribe(t -> System.out.println(\"Phone: \" + t + \" °C\"));\nstation.setTemperature(21.5);\n```\n\n<style scoped>\nsection { display: grid; grid-template-columns: 5fr 6fr; grid-template-rows: auto auto 1fr; column-gap: 28px; align-content: start; font-size: 22px; }\nh1, blockquote { grid-column: 1 / -1; }\nh1 { margin: 0 0 0.2em; }\nblockquote { margin: 0 0 0.5em; font-size: 0.9em; }\np { margin: 0; align-self: center; }\np svg { max-height: 440px; }\npre { font-size: 0.66em; margin: 0; align-self: start; }\n</style>\n"
    },
    {
      "name": "Observer-In-Motion",
      "x": 720,
      "y": 420,
      "text": "# Observer in motion\n\n```mermaid\nsequenceDiagram\n    participant Main\n    participant Station as WeatherStation\n    participant Display\n    participant Phone as PhoneApp\n    Main->>Station: subscribe(display)\n    Main->>Station: subscribe(phone)\n    Main->>+Station: setTemperature(21.5)\n    Station->>Display: onTemperature(21.5)\n    Station->>Phone: onTemperature(21.5)\n    Station-->>-Main: return\n    Note over Station,Phone: The station only knows the WeatherListener interface\n```\n\nThe subject loops over its listeners and calls each one through the interface. Adding a new listener, such as a logger or an alarm, doesn't change `WeatherStation` at all: that's the **Open/Closed Principle**, open for extension and closed for modification.\n\n<style scoped>section { font-size: 24px; } p svg { max-height: 430px; }</style>\n"
    },
    {
      "name": "Which-Pattern-When",
      "x": 480,
      "y": 420,
      "text": "# Which pattern, when?\n\n| If you notice… | Consider |\n|---|---|\n| A `switch` or `if` chain that picks an algorithm | **Strategy** |\n| `new SomeConcreteClass()` where the type ought to vary | **Factory Method** |\n| A class you need, whose interface doesn't fit | **Adapter** |\n| Subclasses multiplying: `MilkCaramelSoyLatte` | **Decorator** |\n| One object calling every interested party by hand | **Observer** |\n| Exactly one shared resource, such as configuration | **Singleton** (carefully) |\n\n> **Patterns are tools, not goals.** Reach for one when the problem is actually in front of you, and prefer refactoring toward a pattern over designing one in up front. Two patterns where one would do is a smell of its own.\n\n<style scoped>section { font-size: 25px; } table { font-size: 0.9em; }</style>\n"
    },
    {
      "name": "Summary",
      "x": 240,
      "y": 420,
      "text": "# Summary and further reading\n\n- A pattern is a **named, proven shape** for a recurring design problem, with known trade-offs.\n- **Creational** patterns control how objects are made, **structural** ones how they fit together, and **behavioural** ones how they share work.\n- You already use them. Find each one in the JDK:\n\n| Pattern | In the JDK |\n|---|---|\n| Strategy | `list.sort(Comparator.comparing(Person::name))` |\n| Decorator | `new BufferedReader(new InputStreamReader(System.in))` |\n| Adapter | `Arrays.asList(array)` |\n| Observer | `java.beans.PropertyChangeListener` |\n| Singleton | `Runtime.getRuntime()` |\n| Factory Method | `Calendar.getInstance()`, `NumberFormat.getInstance()` |\n\n**Read next:** Gamma et al., *Design Patterns* (1994) · Freeman & Robson, *Head First Design Patterns* (2nd ed., 2020) · Bloch, *Effective Java* (3rd ed., 2018) · refactoring.guru/design-patterns\n\n<style scoped>section { font-size: 22px; } table { font-size: 0.85em; } ul { margin: 0.2em 0; }</style>\n"
    }
  ]
}
