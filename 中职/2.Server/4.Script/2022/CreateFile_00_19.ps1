$a = "c:\File\"

if(!(Test-path($a)))
{
    md($a)
}

$b=$a+"File0"
for($i=0;$i -le 9;$i++)
{
    if(!(Test-Path ($b+$i+".txt")))
    {
        New-Item($b+$i+".txt")
    }
    else
    {
        Remove-Item($b+$i+".txt")
        New-Item($b+$i+".txt")
    }
    echo ("File"+$i) > ($b+$i+".txt")
}

for($i=10;$i -le 19;$i++)
{
    if(!(Test-Path ($b+$i+".txt")))
    {
        New-Item($b+$i+".txt")
    }
    else
    {
        Remove-Item($b+$i+".txt")
        New-Item($b+$i+".txt")
    }
    echo ("File"+$i) > ($b+$i+".txt") 
