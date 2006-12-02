###################################################################################################
# $Id: visualization.p,v 1.1 2006/02/09 17:12:53 Sanja Exp $
###################################################################################################
@CLASS
visualization




@object[object;toFile][_strOut;_now]
###################################################################################################
$_strOut[^taint[optimized-as-is][
		^if(!def $object){
			^if($object is "bool"){
				^debugShowBool[$object]
			}{
				^debugShowVoid[$object]
			}
		}{
			^if($object is "date"){^debugShowDate[$object]}
			^if($object is "file"){^debugShowFile[$object]}
			^if($object is "image"){^debugShowImage[$object]}
			^if($object is "bool"){^debugShowBool[$object]}
			^if($object is "table"){^debugShowTable[$object]}
			^if($object is "string"){^debugShowString[$object]}
			^if($object is "int" || $object is "double"){^debugShowDouble[$object]}
			^if($object is "hash"){^debugShowHash[$object]}
		}
]]
^if(def $toFile){
	$_now[^date::now[]]
$_strOut[<br />Begin (${_now.day}.${_now.month}.${_now.year} ${_now.hour}^:${_now.minute}^:${_now.second})^:${_strOut}End<br />]
	^_strOut.save[append;$toFile]
}{
	$result[$_strOut]
}
#end @debugShowObject[]




@debugShowString[text;shash]
###################################################################################################
$result[<strong>^text.replace[^table::create[nameless]{^taint[^#0A	<br>]}]</strong>^if(!def $shash){ (string)}]
#end @debugShowString[]




@debugShowDouble[d;shash]
###################################################################################################
$result[<strong>$d</strong>^if(!def $shash){( (int/double))}]
#end @debugShowDouble[]




@debugShowBool[b;shash]
###################################################################################################
$result[<strong>^if($b){true}{false}</strong>^if(!def $shash){ (bool)}]
#end @debugShowBool[]




@debugShowVoid[v;shash]
###################################################################################################
$result[^if(!def $shash){<strong>�������� �� ���������</strong> (void)}]
#end @debugShowVoid[]




@debugShowFile[f][_f]
###################################################################################################
^try{
	$_f[^file::stat[$f.name]]
	$result[���� <strong>^file:fullpath[$f.name]</strong><br />
	������: <strong>$_f.size ����</strong><br />
	������: <strong>${_f.cdate.day}.${_f.cdate.month}.${_f.cdate.year} � 
	${_f.cdate.hour}�.${_f.cdate.minute}���</strong><br />
	�������: <strong>${_f.mdate.day}.${_f.mdate.month}.${_f.mdate.year} � 
	${_f.mdate.hour}�.${_f.mdate.minute}���</strong><br />
	��������� ��� ��������� � ����� ������������� <strong>${_f.adate.day}.${_f.adate.month}.${_f.adate.year} � 
	${_f.adate.hour}�.${_f.adate.minute}���.</strong><br />
	MIME-��� �����: <strong>$_f.content-type</strong><br />
	^if(${_f.content-type} eq "text/plain" || ${_f.content-type} eq "text/html"){
	������ 100 �������� �����:<br />
	<strong><i>^f.text.left(100)...</i></strong><br />
	��������� 100 �������� �����:<br />
	<strong><i>...^f.text.right(100)</i></strong><br />
	}
	]
}{
	$exception.handled(1)
	$result[<font color="red"><strong>^file:fullpath[$f.name]</strong> (file) �� ������!</font>]
}
#end @debugShowFile[]




@debugShowDate[d]
###################################################################################################
$result[<strong>${d.day}.${d.month}.${d.year}, ${d.hour}��� ${d.minute}��� ${d.second}���. $d.yearday ���� ����</strong>]
#end @debugShowDate[]




@debugShowImage[i]
###################################################################################################
$result[^if(def $i.src){<strong>^i.html[]</strong>}{<strong>����������� ������ ��������� Parser3.</strong>}<br />
������ �����������^: ${i.height}px, ������^: ${i.width}px<br />
^if(def $i.exif){^debugShowHash[$i.exif]}{EXIF ���������� � ����� �����������!<br />}]
#end @debugShowImage[]




@debugShowTable[t][_tcol;_t;_path]
###################################################################################################
^if(^t.columns[] != ^t.flip[]){
	$_path[/^math:uid64[]]
	^t.save[$_path]
	$_t[^table::load[$_path]]
	^file:delete[$_path]
	������ �������� <strong>nameless</strong> ��������!<br />
	^debugShowTable[$_t]
}{
	$_tcol[^t.columns[]]
	$result[<table cellSpacing="1" cellPadding="1" border="1">
	<tr align="center">
	^_tcol.menu{
		<td><strong>$_tcol.column</strong></td>
	}
	</tr>

	^t.menu{
	<tr align="center">
		^_tcol.menu{
		<td>$t.[$_tcol.column]</td>
		}
	</tr>
	}
	</table>]
}
#end @debugShowTable[]




@debugShowHash[h][k;v;_sdiv]
###################################################################################################
^if(!def $caller.$_sdiv){$_sdiv(0)}

^_sdiv.inc(50)

^h.foreach[k;v]{<div style="padding-left: ${_sdiv}px">
	^if(!def $v){
		^if($v is "bool"){
			^$.$k^[^debugShowBool[$v;1]^]<br />
		}{
			^$.$k^[^debugShowVoid[$v;1]^]<br />
		}
	}{
		^if($v is "bool"){^$.$k^[^debugShowBool[$v;1]^]}
		^if($v is "string"){^$.$k^[^debugShowString[$v;1]^]}
		^if($v is "date"){^$.$k^[^debugShowDate[$v]^]}
		^if($v is "image"){^$.$k^[<div style="padding-left: 50px">^debugShowImage[$v]</div>^]}
		^if($v is "file"){^$.$k^[<div style="padding-left: 50px">^debugShowFile[$v]</div>^]}
		^if($v is "table"){^$.$k^[<div style="padding-left: 50px">^debugShowTable[$v]</div>^]}
		^if($v is "int" || $v is "double"){^$.$k^(^debugShowDouble($v;1)^)}
		^if($v is "hash"){
			^_sdiv.inc(50)
			^$.$k^[^debugShowHash[$v]^]
			^_sdiv.dec(50)
		}
	}
</div>}
#end @debugShowHash[]