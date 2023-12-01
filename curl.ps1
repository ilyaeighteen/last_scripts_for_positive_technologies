$request=curl --data "Login=monitor&Password=RotinoM!" http://10.14.6.52/mdbu_ria/Login/DoLogin/ | Out-String
$check=$request -match "true"
if ($check -eq $false)
{
iisreset /restart
}