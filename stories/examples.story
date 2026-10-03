{
  "name": "",
  "description": "",
  "navigation": {
    "show": true,
    "style": "arrows",
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
      "x": -340,
      "y": -180,
      "text": "```js {2,4-5}\nimport { Marp } from '@marp-team/marp-core';\nimport shiki from '@marp-team/marp-core/plugins/shiki';\n\nconst marp = new Marp().use(shiki());\nconst { html, css } = marp.render('# Hello, Marp!');\n```"
    },
    {
      "name": "Node",
      "x": -40,
      "y": 0,
      "text": "```mermaid\nclassDiagram\n  +Animal <|-- Duck\n  +Animal <|-- Fish\n  +Animal: +int age\n  +Animal: +String gender\n  +Animal: +isMammal() bool\n  Duck: +String beakColor\n  Duck: +swim()\n  Duck: +quack()\n```\n"
    },
    {
      "name": "Node 2",
      "x": 0,
      "y": 40,
      "text": "\n\n```mermaid\npackage Sales {\n  class Product {\n    +int id\n  }\n  Product o-- Employees.Manager\n\npackage Employees {\n  class Manager {\n    +int id\n  }\n}\n```"
    },
    {
      "name": "Node 3",
      "x": 40,
      "y": 80,
      "text": "```mermaid\nclassDiagram\n    namespace Company.Engineering.Backend {\n        class Developer {\n            +writeCode()\n        }\n    }\n    namespace Company.Engineering.Frontend {\n        class Designer {\n            +createMockup()\n        }\n    }\n    namespace Company.Engineering {\n        class TechLead {\n            +planSprint()\n        }\n    }\n    TechLead --> Developer : leads\n    TechLead --> Designer : leads\n\n```\n"
    },
    {
      "name": "Node 4",
      "x": 80,
      "y": 120,
      "text": "```mermaid\ngraph LR\n  M[Marpit framework] --> C{Marp Core}\n  C --> CLI[Marp CLI]\n  C --> VS[Marp for VS Code]\n  C --> O[[Your own app]]\n```\n\n<style scoped>\nsvg[data-marp-mermaid] { width: 100%; height: auto; max-height: 540px; }\n</style>"
    },
    {
      "name": "Node 5",
      "x": -300,
      "y": -140,
      "text": "```nomnoml\n#.tesco: visual=package fill=pink\n#.argos: visual=package fill=#8f8\n\n\n[<frame> cd: |\n  [<tesco> tesco |\n    [<class id=beeper> «abstract»;Beeper]\n    [beeper]->1[Piston]\n    [Cylinder]->2[Valve]\n  ]\n  [<argos> argos |\n    [<class id=comp> «abstract»;Compomnent]\n    [comp]<:-[Piston]\n    [comp]<--[Wheel]\n    [comp]<:-[Nut]\n  ]\n]\n```\n"
    },
    {
      "name": "Node 6",
      "x": -260,
      "y": -100,
      "text": "\n```nomnoml\n    [<abstract>Component||+ operation()]\n    [Client] depends --> [Component]\n    [Decorator|- next: Component]\n    [Decorator] decorates -- [ConcreteComponent]\n    [Component] <:- [Decorator]\n    [Component] <:- [ConcreteComponent]\n```"
    },
    {
      "name": "Node 7",
      "x": -220,
      "y": -60,
      "text": "```nomnoml\n#.box: fill=#8f8 dashed\n#.blob: visual=ellipse title=bold\n[<box> GreenBox]\n[<blob> HideousBlob]\n```"
    },
    {
      "name": "Node 8",
      "x": -180,
      "y": -20,
      "text": "```nomnoml\n#.tesco: visual=package fill=pink title=left\n#.argos: visual=package fill=#8f8 title=left\n\n[<frame> cd: |\n  [<tesco> tesco |\n    [beeper]-:>1[Piston]\n    [Cylinder]-:>2[Valve]\n  ]\n  [<argos> argos |\n    [Shelf]->*[Item]\n  ]\n]\n```\n"
    }
  ]
}
