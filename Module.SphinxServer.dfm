object modServerContainer: TmodServerContainer
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 328
  Width = 406
  object SparkleHttpSysDispatcher: TSparkleHttpSysDispatcher
    OnStart = SparkleHttpSysDispatcherStart
    Left = 64
    Top = 56
  end
  object acSphinx: TAureliusConnection
    DriverName = 'SQLite'
    Params.Strings = (
      'EnableForeignKeys=True')
    Left = 200
    Top = 56
  end
  object adbsSphinx: TAureliusDBSchema
    Connection = acSphinx
    ModelNames = 'Biz.Sphinx'
    Left = 192
    Top = 136
  end
  object SphinxServer: TSphinxServer
    Dispatcher = SparkleHttpSysDispatcher
    Pool = SphinxConnectionPool
    Config = SphinxConfig
    Left = 64
    Top = 128
  end
  object SphinxConfig: TSphinxConfig
    Clients = <>
    LoginOptions.ForbidSelfRegistration = True
    PasswordOptions.RequiredLength = 4
    OnConfigureToken = SphinxConfigConfigureToken
    OnGetSigningData = SphinxConfigGetSigningData
    OnGenerateEmailConfirmationToken = SphinxConfigGenerateEmailConfirmationToken
    OnGeneratePasswordResetToken = SphinxConfigGeneratePasswordResetToken
    Left = 64
    Top = 208
  end
  object SphinxConnectionPool: TXDataConnectionPool
    Connection = acSphinx
    Left = 200
    Top = 216
  end
end
