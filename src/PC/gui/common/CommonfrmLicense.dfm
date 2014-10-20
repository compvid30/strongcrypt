object frmLicense: TfrmLicense
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'License'
  ClientHeight = 372
  ClientWidth = 594
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 328
    Width = 578
    Height = 17
    Shape = bsTopLine
  end
  object pbOK: TButton
    Left = 513
    Top = 339
    Width = 73
    Height = 25
    Cancel = True
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 578
    Height = 305
    Lines.Strings = (
      'FreeOTFE Licence (v1.1)'
      ''
      '    1. Definitions'
      
        '        1.1. Original Author: The individual, organization or le' +
        'gal entity identified in Exhibit A'
      
        '        1.2. Original Work: The Source Code, documentation and b' +
        'uilt executables relating to the software identified in Exhibit ' +
        'B'
      
        '        1.3. Derivative Works: Any modified version of the Origi' +
        'nal Work (or product which uses any part of the Original Work) a' +
        'nd any subsequent Derivative Works.'
      
        '        1.4. The Software: The Original Work or any Derivative W' +
        'orks'
      
        '        1.5. You: Any individual, organization or legal entity w' +
        'ishing to use The Software for any purpose.'
      
        '        1.6. Source Code: The complete source code including all' +
        ' related build scripts, images and components required to build ' +
        'the source code into an executable version '
      '    2. Grant of license'
      
        '        2.1 Subject to the terms and conditions of this licence ' +
        'You are granted a world wide, royalty free, non exclusive licenc' +
        'e to use, copy, distribute, display and modify The Software rele' +
        'ased under this licence. '
      '    3. Modifications and Derivative Works'
      
        '        3.1. The Software may be modified in order to produce De' +
        'rivative Works subject to the following:'
      
        '            3.1.1. Derivative Works in executable form must prom' +
        'inently display the notice detailed at Exhibit C whenever the De' +
        'rivative Work is started and in any display and documentation wh' +
        'ere copyright is asserted for the Derivative Works'
      
        '            3.1.2. Derivative Works may not be named or be ident' +
        'ified using any of the names specified in Exhibit D nor use any ' +
        'similar sounding or potentially confusing name'
      
        '            3.1.3. Derivative Works may not use any of the names' +
        ' specified at Exhibit D or that of the Original Author to promot' +
        'e or endorse the Derivative Works without the prior written perm' +
        'ission of the Original Author. '
      
        '        3.2 Derivative Works in executable form may only be dist' +
        'ributed provided that:'
      
        '            3.2.1. Such distributions include a copy of this lic' +
        'ence'
      
        '            3.2.2. The Source Code used to produce the Derivativ' +
        'e Works must be released under this licence'
      
        '            3.2.3. The Source Code used to produce the Derivativ' +
        'e Works must be made freely available to anyone who wishes a cop' +
        'y (including but not limited to the Original Author and any reci' +
        'pient of the Derivative Works) '
      
        '                       for a minimum period starting from the ti' +
        'me at which the Derivative Works are initially distributed to at' +
        ' least two years after the Derivative Works cease to be distribu' +
        'ted. '
      '    4. Termination'
      '        4.1. This licence terminates automatically should You:'
      
        '            4.1.1. Fail to comply with any of the term of this l' +
        'icense'
      
        '            4.1.2. Commence any action including claim, cross-cl' +
        'aim or counterclaim against the Original Author '
      '    5. Disclaimer of Warranty'
      
        '        5.1. THE SOFTWARE COMES WITH NO WARRANTY OF ANY KIND, EI' +
        'THER EXPRESS OR IMPLIED '
      ''
      'Exhibit A'
      'The Original Author is:'
      ''
      '    Sarah Dean '
      ''
      'Exhibit B'
      'The works covered by this licence are:'
      ''
      '    FreeOTFE'
      '    FreeOTFE4PDA'
      '    FreeOTFE Explorer '
      ''
      'Exhibit C'
      'The notice to be shown is:'
      ''
      
        '    This software is based on FreeOTFE and/or FreeOTFE4PDA, the ' +
        'free disk encryption system for PCs and PDAs, available at www.F' +
        'reeOTFE.org '
      ''
      'Exhibit D'
      ''
      'The restricted names are:'
      ''
      '    FreeOTFE'
      '    FreeOTFE4PDA'
      '    FreeOTFE Explorer ')
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
end
