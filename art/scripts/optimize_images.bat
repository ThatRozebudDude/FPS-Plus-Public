@echo off
rem This script goes through every .png in the images folder and optimizes it to reduce file size.
rem This requires oxipng to run. If you don't have it you can get it here: https://github.com/shssoichiro/oxipng/releases
rem This will take a lil' bit to run so be prepared to wait while it does it's thing.
cd../..
cd assets/images
for /R %%f in (*.png) do oxipng -o 6 --strip all --alpha "%%f"
pause