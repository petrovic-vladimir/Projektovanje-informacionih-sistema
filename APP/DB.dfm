object dmDB: TdmDB
  Height = 480
  Width = 640
  object DbConnect: TFDConnection
    Params.Strings = (
      'Database=FITMANAGER'
      'User_Name=Admin'
      'ODBCDriver=ODBC Driver 18 for SQL Server'
      'RDBMS=MSSQL'
      
        'ODBCAdvanced=SERVER=localhost;Trusted_Connection=Yes;APP=Enterpr' +
        'ise/Architect;WSID=DESKTOP-VP333;TrustServerCertificate=Yes'
      'Pooled=MSSQL'
      'DriverID=ODBC')
    Connected = True
    Left = 96
    Top = 80
  end
  object Query_getAllUsers: TFDQuery
    Connection = DbConnect
    SQL.Strings = (
      'SELECT * FROM [User]')
    Left = 256
    Top = 96
  end
end
