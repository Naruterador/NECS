#在E:\share\users目录下新建21个空文件夹，名称为sa00~sa20

$a = "E:\share\users\"
$b = $a+"sa0"

for ($i=0;$i -le 9;$i++)
{
    md ($b+$i)

}
$b = $a+"sa1"

for ($i=0;$i -le 9;$i++)
{
    md ($b+$i)
}
md ($a+"sa20") 
