set SRC_DIR=..\nanquim

xcopy /Y /S "%SRC_DIR%\assets\" assets\
xcopy /Y /S "%SRC_DIR%\bake\" bake\
xcopy /Y "%SRC_DIR%\build\app_wasm.wasm" .
xcopy /Y "%SRC_DIR%\src\nanquim_platform\index.html" .
xcopy /Y "%SRC_DIR%\src\nanquim_platform\nanquim.js" .

rem git add .
rem git commit -m "update"
rem git push
