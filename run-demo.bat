@echo off
set LIB=%CD%\lib
set CLASSPATH=%LIB%\jason.jar;%LIB%\jasonenv.jar;%LIB%\contract-demo.jar

cd src-test

java jason.infra.centralised.RunCentralisedMAS LostWax.mas2j