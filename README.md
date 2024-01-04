# Xedge32 Weather Station App

1. Upload the code in the src directory to a new directory such as weatherstation, using the WebDAV plugin i.e. mount http://xedge.local/rtl/apps/
2. In the Xedge32 IDE, right-click the weatherstation directory and create an app. You must also LSP enable the app.

```
src
 |   .preload - The weather station code
 |   getwd.lsp -- REST service used by index.html
 |   index.html -- Example code for fetching TS data
 |
 \---.lua
        tsdb.lua - Time Series (TS) database
```

