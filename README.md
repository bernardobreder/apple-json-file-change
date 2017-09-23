# Introdução

O componente JsonFileChange tem o objetivo de rastrear as mudanças ocorridas nos arquivos e conteúdo json do sistema de arquivo DataBaseFileSystem.

# Exemplo

O exemplo abaixo irá criar um Json, aplicando algumas mudanças e revertendo

```swift
let fs = MemoryFileSystem()
let jfc = try JsonFileChange(folder: fs.home())

try jfc.write { try $0.createFile([], name: "a.txt") }
jfc.changes.count == 1
jfc.changes[0] == JsonFileChangeCreateFile([], name: "a.txt")
print(try jfc.read{ rjfc in try rjfc.list() }.files) // [a.txt]

try jfc.revert()
print(try jfc.read{ rjfc in try rjfc.list() }.files) // []
```
