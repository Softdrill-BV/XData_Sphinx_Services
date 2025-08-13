object modServerContainer: TmodServerContainer
  OnCreate = DataModuleCreate
  Height = 246
  Width = 431
  object SparkleHttpSysDispatcher: TSparkleHttpSysDispatcher
    Left = 72
    Top = 16
  end
  object XDataServer: TXDataServer
    BaseUrl = 'http://+:2001/example/xdata'
    Dispatcher = SparkleHttpSysDispatcher
    Pool = XDataConnectionPool
    EntitySetPermissions = <>
    Left = 216
    Top = 16
    object XDataServerJWT: TSparkleJwtMiddleware
      ForbidAnonymousAccess = True
      OnGetSecretEx = XDataServerJWTGetSecretEx
    end
  end
  object XDataConnectionPool: TXDataConnectionPool
    Connection = acXData
    Left = 216
    Top = 72
  end
  object acXData: TAureliusConnection
    DriverName = 'SQLite'
    Left = 224
    Top = 144
  end
  object adbsXData: TAureliusDBSchema
    Connection = acXData
    Left = 312
    Top = 152
  end
end
