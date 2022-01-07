#cs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Name..................: BluePrism_UDF
    Description...........: Blue Prism automation functions
    Documentation.........: Blue Prism help file

    Author................: exorcistas@github.com
    Modified..............: 2020-03-27
    Version...............: v0.1a
#ce ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include-once
#include <Constants.au3>

#Region GLOBALS
    Global Const $_BP_AUTOMATEC_DIR = "C:\Program Files\Blue Prism Limited\Blue Prism Automate\"
    Global Const $_BP_AUTOMATEC_EXE = "automateC.exe"

    ;-- configure environment settings here:
    Global Const $_BP_DBCONN_PROD = "Prod"
    Global Const $_BP_DBCONN_TEST = "Test"
    Global Const $_BP_DBCONN_DEV = "Dev"
#EndRegion GLOBALS

#Region FUNCTIONS_LIST
#cs	===================================================================================================================================
%% CORE %%
    _BP_ImportFiles($_sDBCONN, $_sImportPath, $_bSSO = True, $_bOverwrite = True)
    _BP_EnableProcessAlerts($_sDBCONN, $_bSSO = True, $_sUserID = @UserName, $_xPassword = "")

%% INTERNAL %%
    __AutomateC_RunCommand($_sCommand)
#ce	===================================================================================================================================
#EndRegion FUNCTIONS_LIST

#Region CORE_FUNCTIONS

    #cs /import <filespec>
        Imports a Blue Prism process (or visual business object) into the database, 
        by default using the ID found in the file (if one exists - otherwise a new ID is generated). 
        See /forceid to override this behaviour. 
        The filespec parameter refers to location of the xml file to be imported. 
        By default, if the imported process / object already exists in the selected environment, 
        this operation will fail. See /overwrite to avoid this. 
    #ce
    Func _BP_ImportFiles($_sDBCONN, $_sImportPath, $_bOverwrite = True, $_bSSO = True, $_sUserID = @UserName, $_xPassword = "")
        Local $_sDBConnection = "/dbconname " & Chr(34) & $_sDBCONN & Chr(34)
        Local $_sCredentials = ($_bSSO) ? "/sso" : "/user " & $_sUserID & " " & $_xPassword
        Local $_sOverwrite = ($_bOverwrite) ? " /overwrite" : ""

        Local $_sCommand = $_sDBConnection & " " & $_sCredentials & " /import " & Chr(34) & $_sImportPath & Chr(34) & $_sOverwrite

        Local $_sOutput = __AutomateC_RunCommand($_sCommand)
            If (StringInStr(StringUpper($_sOutput), "IMPORTED") = 0) Then SetError(1)
        
        Return SetError(@error, 0, $_sOutput)
    EndFunc

    #cs /alerts
        Starts background Process Alert monitoring. 
        Needs to be used in conjunction with one of the /User or /sso switches 
        so the correct user's Process Alerts configuration is used. 
    #ce
    Func _BP_EnableProcessAlerts($_sDBCONN, $_bSSO = True, $_sUserID = @UserName, $_xPassword = "")
        Local $_sDBConnection = "/dbconname " & Chr(34) & $_sDBCONN & Chr(34)
        Local $_sCredentials = ($_bSSO) ? "/sso" : "/user " & $_sUserID & " " & $_xPassword

        Local $_sCommand = $_sDBConnection & " " & $_sCredentials & " /alerts"
        Local $_sOutput = __AutomateC_RunCommand($_sCommand)

        Return SetError(@error, 0, $_sOutput)
    EndFunc
#EndRegion CORE_FUNCTIONS

#Region INTERNAL
    #cs Command Line Options
        Blue Prism provides two utilities accepting command line switches:

        Automate.exe 
        The graphical Blue Prism application. Any messages or feedback from this application is made visually. A return code of zero indicates success; a non-zero return code indicates an error. 

        AutomateC.exe 
        A commandline utility which returns messages and feedback to the command line (via standard output). A return code of zero indicates success; a non-zero return code indicates an error. 

        Tips:
        Dynamic help is available for AutomateC, using the "/help" switch; under Automate.exe the "/help" switch will show this document, in a graphical window. 
        Some switches require additional parameters, (shown below as <parameter>), which must follow the switch. 
        Switches and parameters are separated by spaces. If the value for a parameter contains spaces or other special characters, it must be enclosed in "quotes". For this reason the actual value cannot contain quotes, so care must be taken to avoid this. 
        When passing XML, you must enclose the xml string in quotation marks. Since quotation marks are used to delimit the start/end of the parameters xml string on standard input, Blue Prism recommends that you delimit your xml attributes using single quote marks. Alternatively, you may escape any quotation marks present, by entering two quotation marks, for each quotation mark within the parameters xml. 
    #ce
    Func __AutomateC_RunCommand($_sCommand)
        ConsoleWrite(@CRLF & ">> AutomateC_RunCommand:  " & $_sCommand & @CRLF)
        Local $_iAutomateC = Run(@ComSpec & " /c " & $_BP_AUTOMATEC_EXE & " " & $_sCommand, $_BP_AUTOMATEC_DIR, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
            ProcessWaitClose($_iAutomateC)

        Local $_stdout = StdoutRead($_iAutomateC)
        ConsoleWrite(">> STDOUT:  " & $_stdout & @CRLF)
        
        Return $_stdout
    EndFunc
#EndRegion INTERNAL