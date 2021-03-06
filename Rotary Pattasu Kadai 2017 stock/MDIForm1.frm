VERSION 5.00
Begin VB.MDIForm MDIForm1 
   BackColor       =   &H8000000C&
   Caption         =   "Rotary Club of Mettupalayam"
   ClientHeight    =   3195
   ClientLeft      =   225
   ClientTop       =   870
   ClientWidth     =   7950
   LinkTopic       =   "MDIForm1"
   Moveable        =   0   'False
   Picture         =   "MDIForm1.frx":0000
   StartUpPosition =   3  'Windows Default
   WindowState     =   2  'Maximized
   Begin VB.Menu mnuitemmaster 
      Caption         =   "&Item Master"
   End
   Begin VB.Menu mnusales 
      Caption         =   "&Sales"
   End
   Begin VB.Menu mnudaybook 
      Caption         =   "&Day Book"
   End
   Begin VB.Menu mnureport 
      Caption         =   "&Report"
      Begin VB.Menu mnustockreport 
         Caption         =   "Current Stock"
      End
      Begin VB.Menu mnusalesperiodreport 
         Caption         =   "Sales Period Wise"
      End
      Begin VB.Menu mnudbreport 
         Caption         =   "Daybook Report"
      End
   End
   Begin VB.Menu mnucalculator 
      Caption         =   "Calc&ulator"
   End
   Begin VB.Menu mnuhelp 
      Caption         =   "&Help"
   End
   Begin VB.Menu mnuexit 
      Caption         =   "E&xit"
   End
End
Attribute VB_Name = "MDIForm1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim db As New ADODB.Connection
Dim rs As New ADODB.Recordset
Dim rs1 As New ADODB.Recordset

'<================================ Printer Code ===========================================>
Private Type DOCINFO
    pDocName As String
    pOutputFile As String
    pDatatype As String
End Type

Private Declare Function ClosePrinter Lib "winspool.drv" (ByVal _
   hPrinter As Long) As Long
Private Declare Function EndDocPrinter Lib "winspool.drv" (ByVal _
   hPrinter As Long) As Long
Private Declare Function EndPagePrinter Lib "winspool.drv" (ByVal _
   hPrinter As Long) As Long
Private Declare Function OpenPrinter Lib "winspool.drv" Alias _
   "OpenPrinterA" (ByVal pPrinterName As String, phPrinter As Long, _
    ByVal pDefault As Long) As Long
Private Declare Function StartDocPrinter Lib "winspool.drv" Alias _
   "StartDocPrinterA" (ByVal hPrinter As Long, ByVal Level As Long, _
   pDocInfo As DOCINFO) As Long
Private Declare Function StartPagePrinter Lib "winspool.drv" (ByVal _
   hPrinter As Long) As Long
Private Declare Function WritePrinter Lib "winspool.drv" (ByVal _
   hPrinter As Long, pBuf As Any, ByVal cdBuf As Long, _
   pcWritten As Long) As Long

Private Sub mnucalculator_Click()
Call Shell("calc.exe", vbNormalFocus)
End Sub

Private Sub mnudaybook_Click()
DBdaybookfrm.Show
End Sub

Private Sub mnudbreport_Click()
daybookRpt.Show
End Sub

Private Sub mnuexit_Click()
End
End Sub

Private Sub mnuhelp_Click()
frmhelp.Show
End Sub

Private Sub mnuitemmaster_Click()
ItemFrm.Show
End Sub

Private Sub mnusales_Click()
SalesFrm1.Show
End Sub

Private Sub mnusalesperiodreport_Click()
SalesPeriodRpt.Show
End Sub

Private Sub mnustockreport_Click()
If db.State = 1 Then db.Close
db.Open "Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Data Source=" & App.Path & "\master.mdb" & ";jet oledb:database password=ragu_24993"

stmt = "select * from tbl_stock"
If rs.State = 1 Then rs.Close
rs.Open stmt, db, adOpenDynamic, adLockOptimistic
If Not rs.EOF Then
    '----------Notepad print------------------
    Open App.Path & "\rptcurrentstock.txt" For Output As #1
    
    Print #1, Chr(27); Chr(77);         ' Printer Pitch 12    Form feed=Chr(12); 10 pitch=Chr(18);
    Print #1, ""
    Print #1, Space(16) & "Rotary Club of Mettupalayam"
    Print #1, ""
    Print #1, "Current Stock as on " & Format(Date, "DD/MM/YYYY") & Space(15) & "Time: " & Time()
    Print #1, "--------------------------------------------------------------"           ' 62
    Print #1, "Item Code" & Space(2) & "Item Name " & Space(20) & Space(2) & "Item Type" & Space(2) & "Quantity"
    Print #1, "--------------------------------------------------------------"
    tqty = 0
    x = 10
    While Not rs.EOF
        If Val(rs.Fields("qty")) <> 0 Then
            tqty = Val(tqty) + Val(rs.Fields("qty"))
        
            icode = 9 - Len(rs.Fields("itemcode"))
            iname = 30 - Len(Mid(rs.Fields("itemname"), 1, 30))
            itype = 9 - Len(rs.Fields("itemtype"))
            iqty = 8 - Len(Format(rs.Fields("qty"), "0.00"))
        
            Print #1, UCase(rs.Fields("itemcode")) & Space(icode) & Space(2) & UCase(Mid(rs.Fields("itemname"), 1, 30)) & Space(iname) & Space(2) & rs.Fields("itemtype") & Space(itype) & Space(2) & Space(iqty) & Format(rs.Fields("qty"), "0.00")
        
            x = x + 1
            If x = 60 Then
                x = 10
                Print #1, Chr(12)
                Print #1, ""
                Print #1, Space(16) & "Rotary Club of Mettupalayam"
                Print #1, ""
                Print #1, "Current Stock as on " & Format(Date, "DD/MM/YYYY") & Space(24) & "     Time: " & Time()
                Print #1, "--------------------------------------------------------------"           ' 62
                Print #1, "Item Code" & Space(2) & "Item Name " & Space(20) & Space(2) & "Item Type" & Space(2) & "Quantity"
                Print #1, "--------------------------------------------------------------"
            End If
        End If
        rs.MoveNext
    Wend
    Print #1, "--------------------------------------------------------------"
    Print #1, Space(47) & "Total: " & Space(iqty) & Format(tqty, "0.00")
    Print #1, "--------------------------------------------------------------"
    Close #1
    retval = Shell("notepad.exe rptcurrentstock.txt", vbMaximizedFocus)
    
    s = MsgBox("Do You Want Print", vbYesNo)
    If s = vbYes Then
        'Open App.Path & "\print.bat" For Output As #1 '//Creating Batch file
        'Print #1, "TYPE rptcurrentstock.txt>PRN"
        'Print #1, "EXIT"
        'Close #1
        'retval = Shell(App.Path & "\print.bat", vbHide)
        '<==================== Printing Code ========================>
        Dim lhPrinter As Long
        Dim lReturn As Long
        Dim lpcWritten As Long
        Dim lDoc As Long
        Dim sWrittenData As String
        Dim MyDocInfo As DOCINFO
        lReturn = OpenPrinter(Printer.DeviceName, lhPrinter, 0)
        If lReturn = 0 Then
            MsgBox "The Printer Name you typed wasn't recognized."
            Exit Sub
        End If
        MyDocInfo.pDocName = "AAAAAA"
        MyDocInfo.pOutputFile = vbNullString
        MyDocInfo.pDatatype = vbNullString
        lDoc = StartDocPrinter(lhPrinter, 1, MyDocInfo)
        Call StartPagePrinter(lhPrinter)
        
        Dim var1 As String
        Open App.Path & "\rptcurrentstock.txt" For Input As #1
        var1 = Input(LOF(1), #1)
        Close #1
        sWrittenData = var1 '& vbFormFeed
        
        lReturn = WritePrinter(lhPrinter, ByVal sWrittenData, _
        Len(sWrittenData), lpcWritten)
        lReturn = EndPagePrinter(lhPrinter)
        lReturn = EndDocPrinter(lhPrinter)
        lReturn = ClosePrinter(lhPrinter)
        '<==================== Printing Code ========================>
    End If
    
End If
End Sub

Private Sub mnuwsalesperiodwise_Click()
'WholeSalesPeriodRpt.Show
End Sub
