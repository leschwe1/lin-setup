---
contents:
  - id: 3
    label: Startup
    language: sh
  - id: 4
    label: Login Credetntials
    language: plain_text
createdAt: 1794938734829
description: null
folderId: 2
id: 2
isDeleted: 0
isFavorites: 0
name: startup
tags: []
updatedAt: 1794938813191
---

## Fragment: Startup
```sh
# in /jdk-26/bin use 
export _JAVA_OPTIONS="-Djdk.security.allowNonCaAnchor=true"     

./java -Djdk.security.allowNonCaAnchor=true --add-opens java.base/java.lang=ALL-UNNAMED -jar /home/leschwe/Documents/SPECCHIO_Client/specchio-client.jar

```

## Fragment: Login Credetntials
```plain_text
localhost
port 443
/specchio_service
jdbc/specchio
```
