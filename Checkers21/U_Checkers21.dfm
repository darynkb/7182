object Form1: TForm1
  Left = 191
  Top = 120
  Caption = 'Checkers V2.1'
  ClientHeight = 562
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Turnlbl: TLabel
    Left = 416
    Top = 16
    Width = 96
    Height = 24
    Caption = 'Red moves'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object MustJumpLbl: TLabel
    Left = 640
    Top = 16
    Width = 47
    Height = 24
    Caption = #1045#1064#1068'!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = MustJumpLblClick
  end
  object Label1: TLabel
    Left = 24
    Top = 456
    Width = 48
    Height = 20
    Caption = #1057#1095#1077#1090':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ScoreLbl1: TLabel
    Left = 24
    Top = 488
    Width = 93
    Height = 20
    Caption = #1050#1088#1072#1089#1085#1099#1077': 0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ScoreLbl2: TLabel
    Left = 192
    Top = 488
    Width = 86
    Height = 20
    Caption = #1063#1077#1088#1085#1099#1077': 0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object UndoLbl: TLabel
    Left = 680
    Top = 480
    Width = 105
    Height = 37
    AutoSize = False
    Caption = #1053#1072#1078#1084#1080#1090#1077' '#1079#1076#1077#1089#1100' '#1076#1083#1103' '#1086#1090#1084#1077#1085#1099' '#1087#1088#1077#1076#1099#1076#1091#1097#1077#1075#1086' '#1076#1077#1081#1089#1090#1074#1080#1103
    WordWrap = True
    OnClick = UndoLblClick
  end
  object StaticText1: TStaticText
    Left = 0
    Top = 542
    Width = 820
    Height = 20
    Cursor = crHandPoint
    Align = alBottom
    Alignment = taCenter
    Caption = #1054#1081#1099#1085' '#1076#1077#1084#1077#1091#1096#1110#1089#1110' - '#1044#1072#1088#1099#1085' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    TabOrder = 0
    OnClick = StaticText1Click
    ExplicitWidth = 183
  end
  object ResetBtn: TButton
    Left = 496
    Top = 476
    Width = 150
    Height = 50
    Caption = #1053#1072#1095#1072#1090#1100' '#1079#1072#1085#1086#1074#1086
    TabOrder = 1
    OnClick = ResetBtnClick
  end
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 329
    Height = 417
    Caption = 'Panel1'
    Color = 14548991
    TabOrder = 2
    object Memo1: TMemo
      Left = 16
      Top = 16
      Width = 313
      Height = 377
      BorderStyle = bsNone
      Color = 14548991
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -23
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Lines.Strings = (
        #1055#1088#1072#1074#1080#1083#1072' '#1080#1075#1088#1099' '#1074' '#1063#1077#1082#1077#1088#1089' '
        #1086#1095#1077#1085#1100' '#1087#1086#1093#1086#1078#1080' '#1085#1072' '#1087#1088#1072#1074#1080#1083#1072' '
        #1080#1075#1088#1099' '#1074' '#1088#1091#1089#1089#1082#1080#1077' '#1096#1072#1096#1082#1080', '#1085#1086' '
        #1080#1084#1077#1102#1090' '#1089#1083#1077#1076#1091#1097#1080#1077' '#1086#1090#1083#1080#1095#1080#1103':'
        '1.'#1055#1088#1086#1089#1090#1072#1103' '#1096#1072#1096#1082#1072' '#1085#1077' '#1084#1086#1078#1077#1090' '
        #1073#1080#1090#1100' '#1085#1072#1079#1072#1076';'
        '2.'#1044#1072#1084#1082#1072' '#1084#1086#1078#1077#1090' '#1093#1086#1076#1080#1090#1100' '
        #1090#1086#1083#1100#1082#1086' '#1085#1072' '#1086#1076#1085#1086' '#1087#1086#1083#1077' '#1074' '
        #1083#1102#1073#1086#1084' '#1085#1072#1087#1088#1072#1074#1083#1077#1085#1080#1080';'
        '3.'#1041#1080#1090#1100' '#1084#1086#1078#1085#1086' '#1087#1088#1086#1080#1079#1074#1086#1083#1100#1085#1086#1077' '
        #1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1096#1072#1096#1077#1082'.'
        #1055#1088#1080#1103#1090#1085#1086#1081' '#1080#1075#1088#1099'!:)')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
end
