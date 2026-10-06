@echo off
chcp 65001 >nul
echo ===================================================
echo       COMPILANDO APP DE RAIZ (.EXE NATIVO)
echo ===================================================

:: Procura o compilador C# nativo do Windows .NET Framework
set "csc=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%csc%" set "csc=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"

if not exist "%csc%" (
    echo [ERRO] O compilador .NET nativo não foi encontrado no sistema.
    pause
    exit /b
)

:: Verifica se o ficheiro HTML existe
if not exist "app.html" (
    echo [ERRO] O ficheiro 'app.html' precisa de estar nesta mesma pasta.
    pause
    exit /b
)

echo [1/3] A gerar código-fonte C# de raiz...

:: Escreve o código C# da janela nativa
(
echo using System;
echo using System.IO;
echo using System.Windows.Forms;
echo using System.Reflection;
echo public class WebAppForm : Form {
echo     private WebBrowser navegador;
echo     [STAThread]
echo     public static void Main^(^) {
echo         Application.EnableVisualStyles^(^);
echo         Application.Run^(new WebAppForm^(^)^);
echo     }
echo     public WebAppForm^(^) {
echo         this.Text = "Aplicação Executável de Raiz";
echo         this.Width = 1024;
echo         this.Height = 768;
echo         this.StartPosition = FormStartPosition.CenterScreen;
echo         navegador = new WebBrowser^(^) { Dock = DockStyle.Fill, ScrollBarsEnabled = false };
echo         this.Controls.Add^(navegador^);
echo         this.Load += new EventHandler^(App_Load^);
echo     }
echo     private void App_Load^(object sender, EventArgs e^) {
echo         try {
echo             string tempPath = Path.Combine^(Path.GetTempPath^(^), "app_html_temp.html"^);
echo             using ^(Stream stream = Assembly.GetExecutingAssembly^(^).GetManifestResourceStream^("app.html"^)^) {
echo                 if ^(stream != null^) {
echo                     using ^(FileStream fileStream = new FileStream^(tempPath, FileMode.Create, FileAccess.Write^)^) {
echo                         stream.CopyTo^(fileStream^);
echo                     }
echo                     navegador.Navigate^(tempPath^);
echo                 } else {
echo                     MessageBox.Show^("Erro ao carregar o recurso interno HTML."^);
echo                 }
echo             }
echo         } catch ^(Exception ex^) {
echo             MessageBox.Show^("Erro: " + ex.Message^);
echo         }
echo     }
echo }
) > temp_app.cs

echo [2/3] A compilar e embutir o HTML dentro do .exe...
:: O parâmetro /resource inclui o app.html dentro do próprio binário executável
:: O parâmetro /target:winexe esconde a janela preta de comando (prompt)
%csc% /target:winexe /resource:app.html /out:MinhaAppNativa.exe temp_app.cs

if %errorlevel% equ 0 (
    echo ===================================================
    echo [SUCESSO] Ficheiro 'MinhaAppNativa.exe' gerado!
    echo ===================================================
) else (
    echo [ERRO] Ocorreu uma falha durante a compilação.
)

echo [3/3] A limpar ficheiros temporários de código...
del temp_app.cs
pause
