﻿#################################################################################################
# $Id: curd.p,v 0.01 12:33 27.12.2006 KleN Exp $
#################################################################################################
@CLASS
curd



#################################################################################################
# Конструктор
@init[hParams][hObject]
# -----------------------------------------------------------------------------------------------
# определение значений по умолчанию
$hObject[
	$.oSql[$MAIN:objSQL]
	$.order[sort_order]
]]
# проверка заданных параметров
^if(!def $hParams.name){^throw[curd;Initialization failure. ^$.name option MUST be specified.]}
# получение параметров
^hObject.add[$hParams]
# -----------------------------------------------------------------------------------------------
# расчеты для скроллера при необходимости
^if(^hObject.s.int(0)){
	$count(^hObject.oSql.int{
		SELECT COUNT(*) FROM $hObject.name
		^if(def $hObject.leftjoin){LEFT JOIN $hObject.leftjoin USING ($hObject.using) }
		^if(def $hObject.where){WHERE $hObject.where }
	})
	^if(def $form:number){$limit(^form:number.int(20))}{$limit($hObject.s)}
	$pagecount(^math:ceiling($count / $limit))
	$page(^form:page.int(1))
	^if($pagecount){$offset(($page - 1) * $limit)}
#	если находимся на странице скроллера упрощаем запрос
	$hObject.offset[$offset]
	$hObject.limit[$limit]
}
# -----------------------------------------------------------------------------------------------
# создание таблицы и хэша
$hObject.tab[^mGetSql[$hObject;$hObject.oSql]]
^if(^hObject.t.int(0) || !def $hObject.h){$table[$hObject.tab]}
^if(^hObject.h.int(0) || !def $hObject.t){$hash[^hObject.tab.hash[id]]}
# получение структуры =debug
# $hObject.structure[^hObject.oSql.sql[table][SHOW COLUMNS FROM $hObject.table][][$.file[${hObject.table}_struct.cache]]]
#end @init[hParams][hObject]


####################################################################################################
# скроллер 
@scroller[hParams][hScroller;iCount;jCode;iFirst;iLast]
# значения по умолчанию
$hScroller[
		$.tag[ascroller]
		$.section(5)
]
^hScroller.add[$hParams]
^if(^hScroller.uri.pos[?]>-1){$sDivider[&]}{$sDivider[?]}
$hScroller.uri[$hScroller.uri?^form:fields.foreach[sKey;sValue]{^if($sKey ne page){$sKey=$sValue&amp^;}}]
# код страничек в промежутке секций
$jCode{^for[iCount]($iFirst;$iLast){<${hScroller.tag}_page count="$iCount" ^if($page == $iCount){select="selected"}/>}}
# код скроллера
<$hScroller.tag count="$count" offset="$offset" limit="$limit" now="^offset.inc($limit)$offset" uri="${hScroller.uri}">
$iFirst(1)
$iLast(1)
# если страниц больше чем секций и текущая страница за секциями
^if($page > $hScroller.section && $pagecount > $hScroller.section){
	$iFirst($page - ($hScroller.section \ 2))
	^if(!$iFirst){$iFirst(1)}
}
^if($pagecount > 1){$iLast($pagecount)}
^if($pagecount > $hScroller.section){$iLast($iFirst + $hScroller.section - 1)}
^if($iLast >= $pagecount){$iLast($pagecount)}
$jCode
# создание левого разделителя секций
^if($iFirst > 1){^iFirst.dec[]<${hScroller.tag}_left uri="${hScroller.uri}page=$iFirst"/>}
# создание правого разделителя секций
^if($pagecount > $hScroller.section && $pagecount != $iLast){^iLast.inc[]<${hScroller.tag}_right uri="${hScroller.uri}page=$iLast"/>}
</$hScroller.tag>
#end @scroller[hParams][hScroller;iCount;jCode;iFirst;iLast]



####################################################################################################
# метод формирующий и выполняющий sql запрос
@mGetSql[hParams;oSql][sRequest]
$sRequest[
	SELECT
		^untaint[as-is]{^hParams.names.foreach[key;value]{$key ^if(def $value){ AS $value }}[,]}
	FROM
		$hParams.name
		^if(def $hParams.leftjoin){ LEFT JOIN $hParams.leftjoin USING ($hParams.using)      }
		^if(def $hParams.where   ){ WHERE     $hParams.where    }
		^if(def $hParams.group   ){ GROUP BY  $hParams.group    }
		^if(def $hParams.order   ){ ORDER BY  $hParams.order    }
		^if(def $hParams.having  ){ HAVING    $hParams.having   }
]
$result[
	^oSql.sql[table][$sRequest][$.limit($hParams.limit)$.offset($hParams.offset)][$.file[${hParams.name}_^math:md5[${sRequest}${hParams.limit}${hParams.offset}].cache]]
]
#end @getSql[hParams]



####################################################################################################
# метод выводящий простенький список данных
@list[hParams][hList]
# параметры по умолчанию
$hList[$.attr[$.id[id]$.name[name]]$.tag[field_option]]
^hList.add[$hParams]
$hList.table[$table]
^hList.table.menu{
	<$hList.tag ^hList.attr.foreach[sKey;sValue]{$sKey = "$hList.table.[$sValue]" }$hList.added>^if(def $hList.value){$hList.table.[$hList.value]}</$hList.tag>
}
#end @list[hParams][hList]



####################################################################################################
# метод выводящий таблицу данных
@draw[hParams][hTable]
$hTable[$.tag[arow]$.scroller(1)]
^hTable.add[$hParams]
# построение шапки таблицы
^hTable.names.menu{<${hTable.tag}_th id="$hTable.names.id">$hTable.names.name</${hTable.tag}_th>}
# построение строк
$hTable.table[$table]
^hTable.table.menu{
<${hTable.tag}_tr id="$hTable.table.id">
^process{@code[hFields]^#OA$hTable.code}
^code[$hTable.table.fields]
#	перебор колонок
	^hTable.names.menu{
		<${hTable.tag}_td
			id="$hTable.names.id"
			value="$hTable.table.[$hTable.names.id]"
			^if(def $hTable.names.object){name="^process[$caller.self]{^$${hTable.names.object}.${hTable.table.[$hTable.names.id]}.name}"}
		 />
	}
</${hTable.tag}_tr>
}
#end @draw[hParams][hTable]